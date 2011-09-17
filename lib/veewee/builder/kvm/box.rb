require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/kvm/build'
require 'veewee/builder/kvm/assemble'
require 'veewee/builder/kvm/destroy'


require 'veewee/builder/kvm/helper/vm'
require 'veewee/builder/kvm/helper/disk'
require 'veewee/builder/kvm/helper/network'
require 'veewee/builder/kvm/helper/console_type'
require 'veewee/builder/kvm/helper/buildinfo'
require 'veewee/builder/kvm/helper/tunnel'


require 'shellwords'

module Veewee
  module Builder
    module Kvm
      class Box < Veewee::Builder::Core::Box
        include Veewee::Builder::Core
        include Veewee::Builder::Kvm

        attr_accessor :connection

        def initialize(environment,box_name,definition_name,box_options={})
          require 'libvirt'
          require 'fog'

          # We only do the internal build for now
          @connection=::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => "qemu:///system")

          super(environment,box_name,definition_name,box_options)
        end

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection
        def ssh_options
          ssh_options={
            :user => @definition.ssh_user,
            :port => 22,
            :password => @definition.ssh_password,
            :timeout => @definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

        def running?
          if exists?
            @connection.servers.all(:name => @box_name).first.ready?
          else
            false
          end
        end

        def exists?
          !@connection.servers.all(:name => @box_name).nil?
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
