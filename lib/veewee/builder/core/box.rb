require 'veewee/builder/core/helper/iso'

module Veewee
  module Builder
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :environment
        attr_accessor :box_name
        attr_accessor :options


        def initialize(environment,box_name,definition_name,box_options)
          @environment=environment
          @options=box_options
          @box_name=box_name
          @definition=@environment.get_definition(definition_name)
        end

        def set_definition(definition_name)
          @definition=@environment.get_definition(definition_name)
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
          kickstartfiles=@definition.kickstart_file

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
              :port => @definition.kickstart_port,
              :host => @definition.kickstart_ip,
              :timeout => @definition.kickstart_timeout,
              :web_dir => File.join(@environment.definition_dir,@box_name)
            })
          end
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
