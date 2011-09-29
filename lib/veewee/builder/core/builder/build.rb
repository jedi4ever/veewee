module Veewee
  module Builder
    module Core
      module BuilderCommand

        def build(definition_name,box_name,options)

          definition=get_definition(definition_name)

          if definition.nil?
            env.ui.error "The definition #{definition_name} does not exist. Sorry"
            exit -1
          end

          # If no box_name was given, let's give the box the same name as the definition
          if box_name.nil?
            box_name=definition_name
          end

          env.ui.info "Building #{definition_name} #{box_name} #{options}"

          # Check the iso file we need to build the box
          verify_iso(definition,options)

          box=get_box(box_name)

          if box.exists?
            # check if --force option was given
            if options[:force]==true
              box.destroy
              box.reload
            else
              env.ui.error "you need to provide --force because the box #{box_name} already exists"
              exit -1
            end
          end

          # By now the box should have been gone, just checking again
          if box.exists?
            env.ui.error "The box should have been deleted by now. Something went terribly wrong. Sorry"
            exit -1
          end

          # By now the machine if it existed, should have been shutdown
          # The last thing to check is if the power we are supposed to ssh to, is still open


          #          if is_tcp_port_open?(box.ip_address, ssh_options(definition)[:port])
          #            env.ui.info "Hmm, the  #{box.ip_address}:#{ssh_options(definition)[:port]} is open. And we shut down?"
          #            exit -1
          #          end

          # Filtering post install files based upon --postinstall-include and --postinstall--exclude
          definition.postinstall_files=filter_postinstall_files(definition,options)

          box.create(definition)

          # Check the GUI mode required
          env.logger.info "Builder asks the box to start: GUI enabled? #{!options[:nogui]}"
          gui_enabled=options[:nogui]==true ? false : true
          box.start(gui_enabled)

          # Waiting for it to boot
          env.ui.info "Waiting #{definition.boot_wait.to_i} seconds for the machine to boot"
          sleep definition.boot_wait.to_i

          # Calculate an available kickstart port
          guessed_port=guess_free_port(definition.kickstart_port.to_i,7199).to_s
          if guessed_port.to_s!=definition.kickstart_port
            env.ui.warn "Changing kickstart port from #{definition.kickstart_port} to #{guessed_port}"
            definition.kickstart_port=guessed_port.to_s
          end

          # Let fill's in the variable we need
          boot_sequence=fill_sequence(definition.boot_cmd_sequence,{
            :ip =>get_local_ip,
            :port => definition.kickstart_port.to_s,
            :name => box.name
          })

          box.console_type(boot_sequence)

          until !box.ip_address.nil?
            env.logger.info "wait for Ip addres"
            sleep 2
          end

          handle_kickstart(definition)

          transfer_buildinfo(box,definition)

          handle_postinstall(box,definition)

          env.ui.confirm "The box #{box_name} was build succesfully!"
          env.ui.info "You can now login to the box with:"
          env.ui.info "\nssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{ssh_options(definition)[:port]} -l #{definition.ssh_user} #{box.ip_address}"

        end

        def filter_postinstall_files(definition,options)
          new_definition=definition.clone

          env.logger.info "Applying the postinstall excludes"
          options["postinstall_exclude"].each do |p|
            env.logger.info "Exclude pattern #{p}"
            new_definition.postinstall_files.collect! { |f| f.match(p) ? f.gsub(/^/,"_"): f}
          end

          env.logger.info "Applying the postinstall includes"
          options["postinstall_include"].each do |p|
            env.logger.info "Include pattern #{p}"
            new_definition.postinstall_files.collect! { |f| f.match(p) ? f.gsub(/^_/,""): f}
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
        def handle_kickstart(definition)

          # Handling the kickstart by web
          kickstartfiles=definition.kickstart_file

          if kickstartfiles.nil? || kickstartfiles.length == 0
            env.ui.info "Skipping webserver as no kickstartfile was specified"
          end

          env.ui.info "Starting a webserver #{definition.kickstart_ip}:#{definition.kickstart_port}\n"

          # Check if the kickstart is an array or a single string
          if kickstartfiles.is_a?(String)
            # Let's turn it into an array
            kickstartfiles=kickstartfiles.split
          end

          # For each kickstart file spinup a webserver and wait for the file to be fetched
          kickstartfiles.each do |kickfile|
            wait_for_http_request(kickfile,{
              :port => definition.kickstart_port,
              :host => definition.kickstart_ip,
              :timeout => definition.kickstart_timeout,
              :web_dir => definition.path
            })
          end
        end


        # This function handles all the post-install scripts
        # It requires a box(to login to) and a definition(listing the postinstall files)
        def handle_postinstall(box,definition)

          definition.postinstall_files.each do |postinstall_file|

            # Filenames of postinstall_files are relative to their definition
            filename=File.join(definition.path,postinstall_file)
            unless File.basename(postinstall_file)=~/^_/
              begin
                when_ssh_login_works(box.ip_address,ssh_options(definition).merge({:timeout => definition.postinstall_timeout.to_i})) do
                  begin
                    env.logger.info "About to transfer #{filename} to the box #{box.name} - #{box.ip_address} - #{ssh_options(definition)}"
                    ssh_transfer_file(box.ip_address,filename,File.basename(filename),ssh_options(definition))
                  rescue RuntimeError => ex
                    env.ui.error "error transfering file #{File.basename(filename)}, possible not enough permissions to write? #{ex}"
                    exit -1
                  end
                  command=definition.sudo_cmd
                  newcommand=command.gsub(/%p/,"#{definition.ssh_password}")
                  newcommand.gsub!(/%u/,"#{definition.ssh_user}")
                  newcommand.gsub!(/%f/,"#{postinstall_file}")
                  begin
                    ssh_exec(box.ip_address,"#{newcommand}",ssh_options(definition))
                  rescue RuntimeError => ex
                    env.ui.error "Error executing the command #{newcommand}: #{ex}"
                    exit -1
                  end
                end
              rescue Net::SSH::AuthenticationFailed
                env.ui.error "Authentication failure"
                exit -1
              end
            else
              env.logger.info "Skipping postinstallfile #{postinstall_file}"
            end
          end
        end


        # Transfer information provide by the builder to the box
        #
        #
        def transfer_buildinfo(box,definition)
          begin
            when_ssh_login_works(box.ip_address,ssh_options(definition).merge({:timeout => definition.postinstall_timeout.to_i})) do
              build_info.each do |info|
                begin
                  infofile=Tempfile.open("#{info[:filename]}")
                  infofile.puts "#{info[:content]}"
                  infofile.rewind
                  env.logger.info "About to transfer buildinfo #{info[:content]} into #{info[:filename]} to the box #{box.name} - #{box.ip_address} - #{ssh_options(definition)}"
                  ssh_transfer_file(box.ip_address,infofile.path,info[:filename],ssh_options(definition))
                  infofile.close
                  infofile.delete
                rescue RuntimeError => ex
                  env.ui.error "Error transfering file #{info[:filename]} failed, possible not enough permissions to write? #{ex}"
                  exit -1
                end
              end
            end
          rescue Net::SSH::AuthenticationFailed
            env.ui.error "Authentication failure"
            exit -1
          end

        end

      end #Module
    end #Module
  end #Module
end #Module
