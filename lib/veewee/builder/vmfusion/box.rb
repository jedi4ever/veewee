require 'veewee/builder/core/box'
require 'veewee/builder/core/box/vnc'

require 'veewee/builder/vmfusion/helper/template'
require 'veewee/builder/vmfusion/helper/create'
require 'veewee/builder/vmfusion/helper/export_ova'
require 'veewee/util/tcp'


module Veewee
  module Builder
    module Vmfusion
      class Box < Veewee::Builder::Core::Box

        include ::Veewee::Builder::Vmfusion::BoxHelper
        include ::Veewee::Builder::Core::BoxCommand

        attr_reader :vnc_port

        def initialize(name,env)

          require 'fission'

          super(name,env)
        end

        # When we create a new box
        # We assume the box is not running
        def create(definition)
          
          @vnc_port=guess_vnc_port
          create_vm(definition)
          create_disk(definition)
        end

        def start(gui_enabled=true)
          if gui_enabled
            raw.start unless raw.nil?
          else
            raw.start({:headless => true}) unless raw.nil?
          end
          
        end

        def stop
          raw.stop unless raw.nil?
        end

        def halt
          raw.halt unless raw.nil?
        end

        def shutdown
          # Should be clean shutdown
          raw.stop unless raw.nil?
        end

        def destroy
          if raw.nil?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            exit -1
          end

          raw.halt if raw.state=="running"
          ::Fission::VM.delete(name)
          # remove it from memory
          @raw=nil
        end

        # Check if box is running
        def ready?
          return false if raw.nil?
          return raw.running?
        end

        # Check if the box already exists
        def exists?
          return raw.exists?
        end

        # Get the IP address of the box
        def ip_address
          return raw.ip_address
        end

        # Type on the console
        def console_type(sequence,type_options={})
          vnc_type(sequence,"localhost",vnc_display_port)
          
          # Once this is over, we can remove the vnc port from the config file
          remove_vnc_port
        end
        
        # This tries to guess a port for the VNC Display
        def guess_vnc_port
          min_port=5920
          max_port=6000
          guessed_port=nil
          
          for port in (min_port..max_port)
            unless is_tcp_port_open?("127.0.0.1", port)
              guessed_port=port
              break
            end
          end

          if guessed_port.nil?
            env.ui.info "No free VNC port available: tried #{min_port}..#{max_port}"
            exit -1
          else
            env.ui.info "Found VNC port #{guessed_port} available"            
          end
  
          return guessed_port
        end
        
        def vnc_display_port
          vnc_port - 5900
        end
        
        def remove_vnc_port
            env.ui.info "Removing vnc_port from #{raw.vmx_path}"
            lines=File.readlines(raw.vmx_path).reject{|l| l =~ /^RemoteDisplay.vnc/}
            File.open(raw.vmx_path, 'w') do |f|  
              f.puts lines 
            end
        end

        private
        def raw
          @raw=::Fission::VM.new(name)
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
