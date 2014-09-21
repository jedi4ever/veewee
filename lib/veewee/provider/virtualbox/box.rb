require 'veewee/provider/core/box'

require 'os'

require 'veewee/provider/virtualbox/box/build'
require 'veewee/provider/virtualbox/box/create'
require 'veewee/provider/virtualbox/box/halt'
require 'veewee/provider/virtualbox/box/poweroff'
require 'veewee/provider/virtualbox/box/destroy'
require 'veewee/provider/virtualbox/box/screenshot'
require 'veewee/provider/virtualbox/box/ssh'
require 'veewee/provider/virtualbox/box/validate_vagrant'
require 'veewee/provider/virtualbox/box/export_vagrant'
require 'veewee/provider/virtualbox/box/helper/create'
require 'veewee/provider/virtualbox/box/helper/ip'
require 'veewee/provider/virtualbox/box/helper/forwarding'
require 'veewee/provider/virtualbox/box/helper/natinterface'
require 'veewee/provider/virtualbox/box/helper/ssh_options'
require 'veewee/provider/virtualbox/box/helper/winrm_options'
require 'veewee/provider/virtualbox/box/helper/guest_additions'
require 'veewee/provider/virtualbox/box/helper/status'
require 'veewee/provider/virtualbox/box/helper/version'
require 'veewee/provider/virtualbox/box/helper/buildinfo'
require 'veewee/provider/virtualbox/box/helper/console_type'
require 'veewee/provider/virtualbox/box/up'

module Veewee
  module Provider
    module Virtualbox
      class Box < Veewee::Provider::Core::Box
        include ::Veewee::Provider::Virtualbox::BoxCommand

        def initialize(name, env)
          @vboxcmd = self.class.determine_vboxcmd
          super(name, env)
        end

        def self.windows_vboxcmd
          # based on Vagrant/plugins/providers/virtualbox/driver/base.rb
          if OS.windows?
            if ENV.key?('VBOX_INSTALL_PATH') ||
               ENV.key?('VBOX_MSI_INSTALL_PATH')
              path = ENV['VBOX_INSTALL_PATH'] || ENV['VBOX_MSI_INSTALL_PATH']
              path.split(File::PATH_SEPARATOR).each do |single|
                vboxmanage = File.join(single, 'VBoxManage.exe')
                return "\"#{vboxmanage}\"" if File.file?(vboxmanage)
              end
            end
          end
          nil
        end

        def self.default_vboxcmd
          'VBoxManage'
        end

        def self.determine_vboxcmd
          @command ||= windows_vboxcmd || default_vboxcmd
        end
      end # End Class
    end # End Module
  end # End Module
end # End Module
