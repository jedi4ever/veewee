module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def build(options={})
          download_vbox_guest_additions_iso(options)
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
