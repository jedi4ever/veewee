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

          box.create(definition)
          box.start(options[:gui])

          #waiting for it to boot
          env.ui.info "Waiting #{definition.boot_wait.to_i} seconds for the machine to boot"
          sleep definition.boot_wait.to_i

          # Let fill's in the variable we need
          boot_sequence=fill_sequence(definition.boot_cmd_sequence,{
            :ip =>Veewee::Util::Tcp.local_ip,
            :port => definition.kickstart_port,
            :name => box.name
          })
          
          box.console_type(boot_sequence)
          
          handle_kickstart(definition)
          
          handle_postinstall(box,definition)
        end

        # This will take a sequence and fill in the variables specified in the options
        # f.i. options={:ip => "name"} will substitute "%IP%" -> "name"
        def fill_sequence(sequence,options)
          filled=sequence.dup
          options.each do |key,value|  
            filled.each do |s|
              s.gsub!("%#{key.upcase}%",value)
            end
          end
          return filled
        end

        # This function handles all the post-install scripts
        # It requires a box(to login to) and a definition(listing the postinstall files) 
        def handle_postinstall(box,definition)

          definition.postinstall_files.each do |postinstall_file|

            # Filenames of postinstall_files are relative to their definition
            filename=File.join(definition.path,postinstall_file)

            Veewee::Util::Ssh.when_ssh_login_works(box.ip_address,ssh_options(definition).merge({:timeout => definition.postinstall_timeout.to_i})) do
              begin
                Veewee::Util::Ssh.transfer_file(box.ip_address,filename,File.basename(filename),ssh_options(definition))
              rescue RuntimeError
                env.ui.error "error transfering file #{File.basename(filename)}, possible not enough permissions to write?"
                exit -1
              end
              command=definition.sudo_cmd
              newcommand=command.gsub(/%p/,"#{definition.ssh_password}")
              newcommand.gsub!(/%u/,"#{definition.ssh_user}")
              newcommand.gsub!(/%f/,"#{postinstall_file}")
              begin
                Veewee::Util::Ssh.execute(box.ip_address,"#{newcommand}",ssh_options(definition))
              rescue RuntimeError
                env.ui.error "Error executing the command #{newcommand}"
                exit -1
              end
            end

          end
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
            Veewee::Util::Web.wait_for_request(kickfile,{
              :port => definition.kickstart_port,
              :host => definition.kickstart_ip,
              :timeout => definition.kickstart_timeout,
              :web_dir => definition.path
            })
          end
        end

      end
    end
  end
end
