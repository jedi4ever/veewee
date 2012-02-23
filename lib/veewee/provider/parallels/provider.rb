require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Parallels
      class Provider < Veewee::Provider::Core::Provider

        #include ::Veewee::Provider::Vmfusion::ProviderCommand

        def check_requirements
          unless self.shell_exec("prlctl --version").status == 0
            raise Veewee::Error,"Could not execute prlctl command. Please install Parallels or make sure prlctl is in the Path"
          end

          unless self.shell_exec("arp -an").status == 0
            raise Veewee::Error,"Could not execute arp command. That should never happen :)"
          end

          unless self.shell_exec("python --version").status == 0
            raise Veewee::Error,"Could not execute python command. Please install or make it available in your path"
          end

          check_file=File.join(File.dirname(__FILE__),'..','..','..','python','parallels_sdk_check.py')
          unless self.shell_exec("python #{check_file}").status == 0
            raise Veewee::Error,"Could not connect to the parallels local service. To make it work, install the Parallels SDK that matches your version of parallels"
          end
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
