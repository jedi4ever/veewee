require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/vmfusion/helper/console_type'
require 'veewee/builder/vmfusion/helper/path'

require 'veewee/builder/vmfusion/helper/vm'
require 'veewee/builder/vmfusion/helper/disk'
require 'veewee/builder/vmfusion/helper/network'

require 'veewee/builder/vmfusion/helper/buildinfo'
require 'veewee/builder/vmfusion/helper/template'

require 'veewee/builder/vmfusion/assemble'
require 'veewee/builder/vmfusion/build'
require 'veewee/builder/vmfusion/destroy'
require 'veewee/builder/vmfusion/export_ova'


require 'shellwords'

module Veewee
  module Builder
    module Vmfusion
      class Box < Veewee::Builder::Core::Box
        include Veewee::Builder::Core
        include Veewee::Builder::Vmfusion

        def initialize(environment,box_name,definition_name,box_options={})
          super(environment,box_name,definition_name,box_options)
          @vmrun_cmd=determine_vmrun_cmd
        end    


        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options
          ssh_options={ 
            :user => @definition.ssh_user, 
            :port => 22,
            :password => @definition.ssh_password,
            :timeout => @definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end
 
        def is_running?
          shellresult=Veewee::Util::Shell.execute("#{fusion_path.shellescape}/vmrun -T ws list")
          return shellresult.stdout.include?("#{vmx_file_path}")
        end


      end # End Class
    end # End Module
  end # End Module
end # End Module