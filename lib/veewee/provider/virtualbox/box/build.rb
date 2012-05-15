module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def build(options={})
          download_vbox_guest_additions_iso(options)

          unless definition.floppy_files.nil?
            unless self.shell_exec("java -version").status == 0
              raise Veewee::Error,"This box contains floppyfiles, to create it you require to have java installed or have it in your path"
            end
          end
          super(options)
        end

      end
    end
  end
end
