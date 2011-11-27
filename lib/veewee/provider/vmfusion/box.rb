require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'

require 'veewee/provider/vmfusion/box/template'
require 'veewee/provider/vmfusion/box/validate_vmfusion'
require 'veewee/provider/vmfusion/box/create'
require 'veewee/provider/vmfusion/box/export_ova'
require 'veewee/provider/core/helper/tcp'


module Veewee
  module Provider
    module Vmfusion
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Vmfusion::BoxCommand
        include ::Veewee::Provider::Core::BoxCommand

        attr_reader :vnc_port

        def initialize(name,env)

          require 'fission'

          super(name,env)
        end

        # When we create a new box
        # We assume the box is not running
        def create(options)
          create_vm
          create_disk
        end

        def start(options)
          gui_enabled=options[:nogui]==true ? false : true
          if gui_enabled
            raw.start unless raw.nil?
          else
            raw.start({:headless => true}) unless raw.nil?
          end

        end

        def stop
          raw.stop unless raw.nil?
        end

        def halt(options={})
          raw.halt unless raw.nil?
        end

        def destroy(options={})
          unless raw.exists?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            exit -1
          end

          raw.halt if raw.state=="running"
          ::Fission::VM.delete(name)
          # remove it from memory
          @raw=nil
        end

        # Check if box is running
        def running?
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

        # http://www.thirdbit.net/articles/2008/03/04/dhcp-on-vmware-fusion/
        def host_ip_as_seen_by_guest
          File.open("/Library/Application Support/VMware Fusion/vmnet8/nat.conf").readlines.grep(/ip = /).first.split(" ")[2]
        end

        def build_info
          info=super
          command="/Library/Application Support/VMware Fusion/vmrun"
          output=IO.popen("#{command.shellescape}").readlines
          info << {:filename => ".vmfusion_version",:content => output[1].split(/ /)[2..3].join.strip}

        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          super(options)

          # When we get here, ssh is available and no postinstall scripts have been executed yet
          # So we begin by transferring the ISO file of the vmware tools

          iso_image="/Library/Application Support/VMware Fusion/isoimages/linux.iso"
          iso_image="/Library/Application Support/VMware Fusion/isoimages/darwin.iso" if definition.os_type_id=~/^Darwin/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/freebsd.iso" if definition.os_type_id=~/^Free/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/windows.iso" if definition.os_type_id=~/^Win/

          env.logger.info "About to transfer vmware tools iso buildinfo to the box #{name} - #{ip_address} - #{ssh_options}"
          self.scp(iso_image,File.basename(iso_image))
        end


        # Type on the console
        def console_type(sequence,type_options={})
          if vnc_enabled?
            vnc_type(sequence,"127.0.0.1",vnc_display_port)
          else
            raise Veewee::Error, "VNC is not enabled"
          end
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

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
        end

#        def remove_vnc_port
#          env.ui.info "Removing vnc_port from #{raw.vmx_path}"
#          lines=File.readlines(raw.vmx_path).reject{|l| l =~ /^RemoteDisplay.vnc/}
#          File.open(raw.vmx_path, 'w') do |f|
#            f.puts lines
#          end
#        end
#
#        def set_vnc_port(port)
#          unless vnc_enabled?
#            env.ui.info "Adding vnc_port #{port} to #{raw.vmx_path}"
#            File.open(raw.vmx_path, 'a') do |f|
#              f.puts 
#            end
#          else
#            raise Veewee::Error,"VNC is already enabled"
#          end
#        end

        def vnc_port
           lines=File.readlines(raw.vmx_path)
           matches=lines.grep(/^RemoteDisplay.vnc.port/)
           if matches.length==0
              raise Veewee::Error,"No VNC port found, maybe it is not enabled?"
           else
              value=matches.first.split("\"")[1].to_i
              return value
           end
        end

        def vnc_enabled?
           lines=File.readlines(raw.vmx_path)
           matches=lines.grep(/^RemoteDisplay.vnc.enabled/)
           if matches.length==0
              return false
           else
              if matches.first.split("\"")[1].downcase == 'true'
                return true
              else
                return false
              end
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
