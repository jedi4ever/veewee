require 'tempfile'

module Veewee
  module Provider
    module Vsphere
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
                self.halt(options)
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

          # Need to ensure any CDROMS are disconnected, otherwise
          # we'll receive an error when importing the OVA
          cdroms = raw.config.hardware.device.grep(RbVmomi::VIM::VirtualCdrom)
          cdrom_changes = cdroms.map do |dev|
            dev = dev.dup
            dev.connectable = dev.connectable.dup
            dev.connectable.connected = false
            dev.connectable.startConnected = false
            { :operation => :edit, :device => dev }
          end
          spec = { :deviceChange => cdrom_changes }
          raw.ReconfigVM_Task(:spec => spec)

      	  host = provider.host
	    	  user = provider.user
	    	  password = provider.password

          connect_string = "vi://#{user}:#{password}@#{host}/#{path}"

          shell_exec("ovftool #{debug} #{flags} #{connect_string.shellescape} #{name}.ova")
        end
      end
    end
  end
end
