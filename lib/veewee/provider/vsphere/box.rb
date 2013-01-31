require 'rbvmomi'

require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'
require 'veewee/provider/core/helper/tcp'

require 'veewee/provider/vsphere/box/helper/status'
require 'veewee/provider/vsphere/box/helper/ip'
require 'veewee/provider/vsphere/box/helper/ssh_options'
require 'veewee/provider/vsphere/box/helper/vnc'
require 'veewee/provider/vsphere/box/helper/console_type'
require 'veewee/provider/vsphere/box/helper/buildinfo'
require 'veewee/provider/vsphere/box/helper/vsphere'

require 'veewee/provider/vsphere/box/build'
require 'veewee/provider/vsphere/box/up'
require 'veewee/provider/vsphere/box/create'
require 'veewee/provider/vsphere/box/poweroff'
require 'veewee/provider/vsphere/box/halt'
require 'veewee/provider/vsphere/box/destroy'
require 'veewee/provider/vsphere/box/validate_vsphere'
require 'veewee/provider/vsphere/box/ssh'
require 'veewee/provider/vsphere/box/export_ova'

#VIM = RbVmomi::VIM
# Include RbVmomi extensions for uploading files without curl
#VIM.add_extension_dir File.join(File.dirname(__FILE__), "extensions")

module Veewee
  module Provider
    module Vsphere
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Vsphere::BoxCommand
        include ::Veewee::Provider::Core::BoxCommand


        def initialize(name,env)
      	  super(name,env)
        end

        def vim
      	  vsphere_server = provider.vsphere_server
	    	  vsphere_user = provider.vsphere_user
	    	  vsphere_password = provider.vsphere_password
          @vim ||= RbVmomi::VIM.connect host: vsphere_server, user: vsphere_user, password: vsphere_password, insecure: true
        end

        def raw
          @raw ||= dc.find_vm(name)
        end

        #Path to the VM relative to the host server (vCenter of vSphere)
        def path
          path = dc.name + "/" + dc.vmFolder.name + "/" + name
        end
      end # End Class
    end # End Module
  end # End Module
end # End Module
