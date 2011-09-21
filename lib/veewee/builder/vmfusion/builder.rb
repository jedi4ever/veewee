require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Vmfusion
      class Builder < Veewee::Builder::Core::Builder
          
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
          

                   
      end #End Class
    end # End Module
  end # End Module
end # End Module