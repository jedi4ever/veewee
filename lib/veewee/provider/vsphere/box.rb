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
require 'veewee/provider/vsphere/box/ssh'
require 'veewee/provider/vsphere/box/template'
#require 'veewee/provider/vsphere/box/export_ova'


module Veewee
  module Provider
    module Vsphere
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Vsphere::BoxCommand
        include ::Veewee::Provider::Core::BoxCommand


        def initialize(name,env)
          require 'rbvmomi'
      	  super(name,env)
        end
	
        def vim
      	  host = provider.host
	    	  user = provider.user
	    	  password = provider.password
          @vim ||= RbVmomi::VIM.connect host: host, user: user, password: password, insecure: true 
        end

        def raw
          @raw ||= vim.serviceInstance.find_datacenter.find_vm(name) 
        end
      end # End Class
    end # End Module
  end # End Module
end # End Module
