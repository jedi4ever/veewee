require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/virtualbox/assemble'
require 'veewee/builder/virtualbox/build'
require 'veewee/builder/virtualbox/destroy'
require 'veewee/builder/virtualbox/export_vagrant'
require 'veewee/builder/virtualbox/validate_vagrant'

require 'veewee/builder/virtualbox/helper/vm'
require 'veewee/builder/virtualbox/helper/disk'
require 'veewee/builder/virtualbox/helper/controller'
require 'veewee/builder/virtualbox/helper/floppy'
require 'veewee/builder/virtualbox/helper/dvd'
require 'veewee/builder/virtualbox/helper/network'
require 'veewee/builder/virtualbox/helper/shared_folder'

require 'veewee/builder/virtualbox/helper/console_type'
require 'veewee/builder/virtualbox/helper/buildinfo'
require 'veewee/builder/virtualbox/helper/supress_messages'

module Veewee
  module Builder
    module Virtualbox
    class Box < Veewee::Builder::Core::Box
      include Veewee::Builder::Core
      include Veewee::Builder::Virtualbox
      
      def initialize(environment,box_name,definition_name,builder_options={})
        super(environment,box_name,definition_name,builder_options)
        @vboxcmd=determine_vboxcmd
      end    

      def determine_vboxcmd
         return "VBoxManage"
      end   

      def ssh_options 
        ssh_options={ 
          :user => @definition.ssh_user, 
          :port => @definition.ssh_host_port,
          :password => @definition.ssh_password,
          :timeout => @definition.ssh_login_timeout.to_i
        }
        return ssh_options
        
      end



    end # End Class
end # End Module
end # End Module
end # End Module