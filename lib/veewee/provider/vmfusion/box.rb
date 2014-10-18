require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'
require 'veewee/provider/core/helper/tcp'

require 'veewee/provider/vmfusion/box/helper/status'
require 'veewee/provider/vmfusion/box/helper/ip'
require 'veewee/provider/vmfusion/box/helper/vnc'
require 'veewee/provider/vmfusion/box/helper/console_type'
require 'veewee/provider/vmfusion/box/helper/buildinfo'

require 'veewee/provider/vmfusion/box/build'
require 'veewee/provider/vmfusion/box/up'
require 'veewee/provider/vmfusion/box/create'
require 'veewee/provider/vmfusion/box/poweroff'
require 'veewee/provider/vmfusion/box/halt'
require 'veewee/provider/vmfusion/box/destroy'
require 'veewee/provider/vmfusion/box/ssh'
require 'veewee/provider/vmfusion/box/template'
require 'veewee/provider/vmfusion/box/validate_vmfusion'
require 'veewee/provider/vmfusion/box/export'
require 'veewee/provider/vmfusion/box/add_share'


module Veewee
  module Provider
    module Vmfusion
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Vmfusion::BoxCommand
        include ::Veewee::Provider::Core::BoxCommand


        def initialize(name,env)

          require 'fission'
          super(name,env)
        end

        def vmrun_cmd
          return ::Fission.config['vmrun_bin']
        end

        def vm_path
          return File.join(::Fission.config['vm_dir'], "#{name}.vmwarevm")
        end

        def vmx_file_path
          return "#{vm_path}/#{name}.vmx"
        end

        private
        def raw
          @raw=::Fission::VM.new(name)
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
