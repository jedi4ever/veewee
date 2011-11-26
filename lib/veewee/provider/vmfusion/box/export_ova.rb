require 'tempfile'

module Veewee
  module Provider
    module Vmfusion
      module BoxCommand
        # This function 'exports' the box based on the definition
        def export_ova(options)
          debug="--X:logToConsole=true --X:logLevel=\"verbose\""
          debug=""
          flags="--compress=9"

          if File.exists?("#{name}.ova")
            if options["force"]
              env.logger.debug("#{name}.ova exists, but --force was provided")
              env.logger.debug("removing #{name}.ova first")
              FileUtils.rm("#{name}.ova")
              env.logger.debug("#{name}.ova removed")
            else
              raise Veewee::Error, "export file #{name}.ova already exists. Use --force option to overwrite."
            end
          end

          # Need to check binary first
          if self.running?
            # Wait for the shutdown to complete
            begin
              Timeout::timeout(20) do
                self.shutdown(options)
                status=self.running?
                unless status
                  return
                end
                sleep 4
              end
            rescue TimeoutError::Error => ex
              raise Veewee::Error,ex
            end
          end

          # before exporting the system needs to be shut down

          # otherwise the debug log will show - The specified virtual disk needs repair
          shell_exec("#{fusion_path.shellescape}/ovftool/ovftool.bin #{debug} #{flags} #{vmx_file_path.shellescape} #{name}.ova")
        end
      end
    end
  end
end
