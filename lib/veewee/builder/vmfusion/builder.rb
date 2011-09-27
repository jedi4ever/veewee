require 'veewee/builder/core/builder'
require 'veewee/builder/vmfusion/helper/validate_vmfusion'


module Veewee
  module Builder
    module Vmfusion
      class Builder < Veewee::Builder::Core::Builder

        include ::Veewee::Builder::Vmfusion::BuilderHelper


        def check_requirements
          unless gem_available?("fission")
            raise ::Veewee::Error, "The Vmfusion Builder requires the gem 'fission' to be installed\n"+ "gem install fission"
          end
        end

        def build_info
          info=super
          command="/Library/Application Support/VMware Fusion/vmrun"
          output=IO.popen("#{command.shellescape}").readlines
          info << {:filename => ".vmfusion_version",:content => output[1].split(/ /)[2..3].join.strip}

        end

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options(definition)
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
        end


        #
        
        # Transfer information provide by the builder to the box
        #
        #
          def transfer_buildinfo(box,definition)
            super(box,definition)

            # When we get here, ssh is available and no postinstall scripts have been executed yet
            # So we begin by transferring the ISO file of the vmware tools
            
            iso_image="/Library/Application Support/VMware Fusion/isoimages/linux.iso"
            iso_image="/Library/Application Support/VMware Fusion/isoimages/darwin.iso" if definition.os_type_id=~/^Darwin/
            iso_image="/Library/Application Support/VMware Fusion/isoimages/freebsd.iso" if definition.os_type_id=~/^Free/
            iso_image="/Library/Application Support/VMware Fusion/isoimages/windows.iso" if definition.os_type_id=~/^Win/
            
            begin
              Veewee::Util::Ssh.when_ssh_login_works(box.ip_address,ssh_options(definition).merge({:timeout => definition.postinstall_timeout.to_i})) do
                  begin
                    env.logger.info "About to transfer vmware tools iso buildinfo to the box #{box.name} - #{box.ip_address} - #{ssh_options(definition)}"
                    Veewee::Util::Ssh.transfer_file(box.ip_address,iso_image,File.basename(iso_image),ssh_options(definition))
                  rescue RuntimeError => ex
                    env.ui.error "Error transfering vmware tools iso , possible not enough permissions to write? #{ex}"
                    exit -1
                  end
              end
            rescue Net::SSH::AuthenticationFailed
              env.ui.error "Authentication failure"
              exit -1
            end            

          end




      end #End Class
    end # End Module
  end # End Module
end # End Module
