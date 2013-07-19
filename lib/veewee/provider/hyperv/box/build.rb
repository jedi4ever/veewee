module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def build(options={})

          if !definition.hyperv_host
            #TODO: Get-VMHost to list possible HyperV hosts if non defined
            raise Veewee::Error, "You must specify a hyperv_host in your definition file"
          end

          super(options)

          if definition.floppy_files
            unless self.shell_exec("java -version").status == 0
              raise Veewee::Error, "This box contains floppyfiles, to create it you require to have java installed or have it in your path"
            end
          end

        end

      end
    end
  end
end
