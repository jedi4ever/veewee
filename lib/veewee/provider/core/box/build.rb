module Veewee
  module Provider
    module Core
      module BoxCommand

        def build(options={})

          # Requires valid definition

          ui.info "Building Box #{name} with Definition #{definition.name}:"
          options.each do |name,value|
            ui.info "- #{name} : #{value}"
          end

          # Checking regexp of postinstall include/excludes
          validate_postinstall_regex(options)

          # Check the iso file we need to build the box
          definition.verify_iso(options)

          if self.exists?
            # check if --force option was given
            if options['force']==true
              self.destroy
              self.reload
            else
              ui.error("you need to provide --force because the box #{name} already exists",:prefix => false)
              raise Veewee::Error,"you need to provide --force because the box #{name} already exists"
            end
          end

          # By now the box should have been gone, just checking again
          if self.exists?
            ui.error("The box should have been deleted by now. Something went terribly wrong. Sorry",:prefix => false)
            raise Veewee::Error, "The box should have been deleted by now. Something went terribly wrong. Sorry"
          end

          self.create(options)

          # Check the GUI mode required
          env.logger.info "Provider asks the box to start: GUI enabled? #{!options['nogui']}"
          self.up(options)

          # Waiting for it to boot
          ui.info "Waiting #{definition.boot_wait.to_i} seconds for the machine to boot"
          sleep definition.boot_wait.to_i

          # Calculate an available kickstart port
          unless definition.kickstart_port.nil?
            guessed_port=guess_free_port(definition.kickstart_port.to_i,7199).to_s
            if guessed_port.to_s!=definition.kickstart_port
              ui.warn "Changing kickstart port from #{definition.kickstart_port} to #{guessed_port}"
              definition.kickstart_port=guessed_port.to_s
            end
          end

          # Let fill's in the variable we need
          boot_sequence=fill_sequence(definition.boot_cmd_sequence,{
            :ip =>host_ip_as_seen_by_guest,
            :port => definition.kickstart_port.to_s,
            :name => name
          })

          # Type the boot sequence
          self.console_type(boot_sequence)

          self.handle_kickstart(options)

          # Wait for an ipaddress
          # This needs to be done after the kickstart:
          # As the dhcp request will likely occur just before the kickstart fetch
          until !self.ip_address.nil?
            env.logger.info "wait for Ip addres"
            sleep 2
          end

          self.transfer_buildinfo(options)

          # Filtering post install files based upon --postinstall-include and --postinstall--exclude
          definition.postinstall_files=filter_postinstall_files(options)

          self.handle_postinstall(options)

          ui.success "The box #{name} was built succesfully!"
          ui.info "You can now login to the box with:"
          ui.info ssh_command_string

          return self
        end

        def validate_postinstall_regex(options)
          env.logger.info "Checking the postinstall excludes"
          unless options["postinstall_exclude"].nil?
            options["postinstall_exclude"].each do |p|
              begin
                r=::Regexp.new(p)
              rescue ::RegexpError => ex
                raise Veewee::Error ,"\nError in postinstall exclude (ruby regexp) pattern: #{p}:\n- #{ex}"
              end
            end
          end

          env.logger.info "Checking the postinstall includes"
          unless options["postinstall_include"].nil?
            options["postinstall_include"].each do |p|
              begin
                r=Regexp.new(p)
              rescue RegexpError => ex
                raise Veewee::Error ,"\nError in postinstall include (ruby regexp) pattern: #{p}:\n- #{ex}"
              end
            end
          end
        end

        def filter_postinstall_files(options)
          new_definition=definition.clone

          env.logger.info "Applying the postinstall excludes"
          unless options["postinstall_exclude"].nil?
            options["postinstall_exclude"].each do |p|
              env.logger.info "Exclude pattern #{p}"
              new_definition.postinstall_files.collect! { |f| f.match(p) ? f.gsub(/^/,"_"): f}
            end
          end

          env.logger.info "Applying the postinstall includes"
          unless options["postinstall_include"].nil?
            options["postinstall_include"].each do |p|
              env.logger.info "Include pattern #{p}"
              new_definition.postinstall_files.collect! { |f| f.match(p) ? f.gsub(/^_/,""): f}
            end
          end

          env.logger.info "filtered postinstall files:"
          new_definition.postinstall_files.each do |p|
            env.logger.info "- "+p
          end

          return new_definition.postinstall_files
        end



        # This will take a sequence and fill in the variables specified in the options
        # f.i. options={:ip => "name"} will substitute "%IP%" -> "name"
        def fill_sequence(sequence,options)
          filled=sequence.dup
          options.each do |key,value|
            filled.each do |s|
              s.gsub!("%#{key.to_s.upcase}%",value)
            end
          end
          return filled
        end

        def build_info
          [ {:filename => ".veewee_version",:content => "#{Veewee::VERSION}"}]
        end

        # This function handles all the post-install scripts
        # It requires a definition to find all the necessary information
        def handle_kickstart(options)

          # Handling the kickstart by web
          kickstartfiles=definition.kickstart_file

          if kickstartfiles.nil? || kickstartfiles.length == 0
            ui.info "Skipping webserver as no kickstartfile was specified"
          end

          ui.info "Starting a webserver #{definition.kickstart_ip}:#{definition.kickstart_port}\n"

          # Check if the kickstart is an array or a single string
          if kickstartfiles.is_a?(String)
            # Let's turn it into an array
            kickstartfiles=kickstartfiles.split
          end

          # For each kickstart file spinup a webserver and wait for the file to be fetched
          unless kickstartfiles.nil?
            kickstartfiles.each do |kickfile|
              wait_for_http_request(kickfile,{
                :port => definition.kickstart_port,
                :host => definition.kickstart_ip,
                :timeout => definition.kickstart_timeout,
                :web_dir => definition.path
              })
            end
          end
        end

        # This function handles all the post-install scripts
        # It requires a box(to login to) and a definition(listing the postinstall files)
        def handle_postinstall(options)

          # Transfer all postinstall files
          definition.postinstall_files.each do |postinstall_file|
            # Filenames of postinstall_files are relative to their definition
            filename=File.join(definition.path,postinstall_file)
            self.scp(filename,File.basename(filename))
            self.exec("chmod +x \"#{File.basename(filename)}\"")
          end

          # Prepare a pre_poinstall file if needed (not nil , or not empty)
          unless definition.pre_postinstall_file.to_s.empty?
            pre_filename=File.join(definition.path, definition.pre_postinstall_file)
            self.scp(pre_filename,File.basename(pre_filename))
            self.exec("chmod +x \"#{File.basename(pre_filename)}\"")
            # Inject the call to the real script by executing the first argument (it will be the postinstall script file name to be executed)
            self.exec("execute=\"\\n# We must execute the script passed as the first argument\\n\\$1\" && printf \"%b\\n\" \"$execute\" >> #{File.basename(pre_filename)}")
          end

          # Now iterate over the postinstall files
          definition.postinstall_files.each do |postinstall_file|
            # Filenames of postinstall_files are relative to their definition
            filename=File.join(definition.path,postinstall_file)

            unless File.basename(postinstall_file).start_with?("_")

              unless definition.pre_postinstall_file.to_s.empty?
                # Filename of pre_postinstall_file are relative to their definition
                pre_filename=File.join(definition.path, definition.pre_postinstall_file)
                # Upload the pre postinstall script if not already transfered
                command = "./" + File.basename(pre_filename)
                command = sudo(command) + " ./"+File.basename(filename)
              else
                command = "./"+File.basename(filename)
                command = sudo(command)
              end

              self.exec(command)

            else
              env.logger.info "Skipping postinstallfile #{postinstall_file}"
            end
          end
        end

        # Transfer information provide by the Provider to the box
        #
        #
        def transfer_buildinfo(options)
          build_info.each do |info|
            begin
              infofile=Tempfile.open("#{info[:filename]}")
              # Force binary mode to prevent windows from putting CR-LF end line style
              # http://www.ruby-forum.com/topic/127453#568546
              infofile.binmode
              infofile.puts "#{info[:content]}"
              infofile.rewind
              infofile.close
              self.scp(infofile.path,info[:filename])
              infofile.delete
            rescue RuntimeError => ex
              ui.error("Error transfering file #{info[:filename]} failed, possible not enough permissions to write? #{ex}",:prefix => false)
              raise Veewee::Error,"Error transfering file #{info[:filename]} failed, possible not enough permissions to write? #{ex}"
            end
          end
        end


      end #Module
    end #Module
  end #Module
end #Module
