require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'
require 'veewee/provider/kvm/box/validate_kvm'

require 'veewee/provider/kvm/box/build'
require 'veewee/provider/kvm/box/create'
require 'veewee/provider/kvm/box/up'
require 'veewee/provider/kvm/box/halt'
require 'veewee/provider/kvm/box/poweroff'
require 'veewee/provider/kvm/box/destroy'
require 'veewee/provider/kvm/box/export_vagrant'

require 'veewee/provider/kvm/box/helper/ip'
require 'veewee/provider/kvm/box/helper/status'
require 'veewee/provider/kvm/box/helper/console_type'

module Veewee
  module Provider
    module Kvm
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Core
        include ::Veewee::Provider::Kvm

        include ::Veewee::Provider::Core::BoxCommand
        include ::Veewee::Provider::Kvm::BoxCommand

        attr_accessor :connection

        def initialize(name,env)

          super(name,env)

          @connection=::Fog::Compute[:libvirt]

          # Many of the existing templates have disk_format set to "VDI"
          # Use "qcow2" instead as a vagrant-libvirt-compatible default
          definition.disk_format.downcase!
          definition.disk_format = "qcow2" if definition.disk_format == "vdi"
          @volume_name = "#{name}.#{definition.disk_format}"

        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
