module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def build(options={})
          download_vbox_guest_additions_iso(options)

          unless definition.floppy_files.nil?
            unless self.shell_exec("java").status == 0
              raise Veewee::Error,"This box contains floppyfiles, to create it you require to have java installed or have it in your path"
            end
          end
          super(options)
        end

        def handle_authorized_keys(options)
          pubkey = File.join(@env.definition_dir, @name, 'vagrant.pub')
          return unless File.exist?(pubkey)
          self.scp(pubkey, '.ssh/authorized_keys')
        end

      end
    end
  end
end
