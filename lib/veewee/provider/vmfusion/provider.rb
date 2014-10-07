require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Vmfusion
      class Provider < Veewee::Provider::Core::Provider

        #include ::Veewee::Provider::Vmfusion::ProviderCommand

        def check_requirements
          require 'fission'

          if
            ::Fission.config.attributes["vmrun_bin"].nil? ||
            !File.exists?(::Fission.config.attributes["vmrun_bin"])
          then
            raise Veewee::Error,"Could not find vmrun at standard locations. Probably you don't have Vmware fusion installed"
          end
          env.logger.info("Found fusion version: #{fusion_version}")
        end

        def fusion_version
          # We ask the system profiler for all installed software
          shell_results = shell_exec("system_profiler SPApplicationsDataType", :external_encoding => Encoding::UTF_8)

          env.logger.info("Checking version by querying the system_profiler")
          env.logger.debug(shell_results.stdout)

          if shell_results.stdout == ""
            ui.warn "Could not detect the exact version of vmware. assuming 5.1"
            version = "5.1"
          else
            version = shell_results.stdout.split(/VMware/)[1].split(/\n/)[2].split(/:/)[1].strip
          end

          return version
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
