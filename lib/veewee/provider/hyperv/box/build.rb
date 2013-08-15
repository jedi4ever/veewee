module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def build(options={})

          if definition.floppy_files
            unless self.shell_exec("java -version").status == 0
              raise Veewee::Error,"This box contains floppyfiles, to create it you require to have java installed or have it in your path"
            end
          end

          super(options)

          #powershell_exec "Remove-VMDvdDrive -VMName #{name} -ControllerNumber 1 -ControllerLocation 1"

        end

      end
    end
  end
end
