module Veewee  
  module Builder
    module Core
      module BuilderCommand

        def get_definition(name)
          return env.config.definitions[name]
        end
        
        def get_box(name)
          begin
            require_path='veewee/builder/'+type.to_s.downcase+"/box.rb"
            require require_path

            # Get a real box object from the builder
            box=Object.const_get("Veewee").const_get("Builder").const_get(type.to_s.capitalize).const_get("Box").new(name,env)
          rescue Error => ex
            env.ui.error "Could not instante the box #{name} with provider #{type} ,#{ex}"            
          end
        end
        
        def build(definition_name,box_name,options)
      
          # If no box_name was given, let's give the box the same name as the definition
          if box_name.nil?
            box_name=definition_name
          end
          
          env.ui.info "building #{definition_name} #{box_name} #{options}"

          definition=get_definition(definition_name)

          box=get_box(box_name)

          if box.exists?
            # check if --force option was given
            if options[:force]==true
              box.destroy
              box.reload
            else
              env.ui.error "you need to provide --force because the box #{box_name} already exists"
            end            
          end
          
          # By now the box should have been gone, just checking again          
          if box.exists?
            env.ui.error "The box should have been deleted by now. Something went terribly wrong. Sorry"            
          end
          
          box.create(definition)         
          
        end
           
        def handle_postinstall

          @definition.postinstall_files.each do |postinstall_file|

            # Filenames of postinstall_files are relative to their definition
            filename=File.join(@environment.definition_dir,@box_name,postinstall_file)

            Veewee::Util::Ssh.when_ssh_login_works(ip_address,ssh_options) do
              begin
                Veewee::Util::Ssh.transfer_file(ip_address,filename,File.basename(filename),ssh_options)
              rescue RuntimeError
                puts "error transfering file, possible not enough permissions to write?"
                exit
              end
              command=@definition.sudo_cmd
              newcommand=command.gsub(/%p/,"#{@definition.ssh_password}")
              newcommand.gsub!(/%u/,"#{@definition.ssh_user}")
              newcommand.gsub!(/%f/,"#{postinstall_file}")
              Veewee::Util::Ssh.execute(ip_address,"#{newcommand}",ssh_options)
            end

          end
        end

        def handle_kickstart
          # Handling the kickstart by web
          kickstartfiles=definition.kickstart_file

          if kickstartfiles.nil? || kickstartfiles.length == 0
            puts "Skipping webserver as no kickstartfile was specified"
          end

          puts "Starting a webserver on port #{@definition.kickstart_port}"
          #:kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 1000,:kickstart_file => "preseed.cfg",
          if kickstartfiles.is_a?(String)
            # Let's turn it into an array
            kickstartfiles=kickstartfiles.split
          end

          kickstartfiles.each do |kickfile|
            Veewee::Util::Web.wait_for_request(kickfile,{
              :port => definition.kickstart_port,
              :host => definition.kickstart_ip,
              :timeout => definition.kickstart_timeout,
              :web_dir => File.join(@environment.definition_dir,@box_name)
            })
          end
        end
        
        
      end
    end
  end
end