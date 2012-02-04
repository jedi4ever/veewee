require 'veewee/provider/core/box'

require 'veewee/provider/virtualbox/box/create'
require 'veewee/provider/virtualbox/box/console_type'
require 'veewee/provider/virtualbox/box/destroy'
require 'veewee/provider/virtualbox/box/validate_vagrant'
require 'veewee/provider/virtualbox/box/export_vagrant'

module Veewee
  module Provider
    module Virtualbox
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Virtualbox::BoxCommand

        def initialize(name,env)

          require 'virtualbox'
          @vboxcmd=determine_vboxcmd
          super(name,env)

        end

        def determine_vboxcmd
          return "VBoxManage"
        end

        def exists?
          vm=VirtualBox::VM.find(name)
          env.logger.info("Vm exists? #{!vm.nil?}")
          return !vm.nil?
        end

        def running?
          return !raw.powered_off?
        end

        def create(options={})

          guessed_port=guess_free_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
          if guessed_port.to_s!=definition.ssh_host_port
            env.ui.warn "Changing ssh port from #{definition.ssh_host_port} to #{guessed_port}"
            definition.ssh_host_port=guessed_port.to_s
          end


          # Suppress those annoying virtualbox messages
          suppress_messages

          create_vm

          # Attach ttyS0 to the VM for console output
          redirect_console=options[:redirectconsole]
          if redirect_console
            attach_serial_console
          end

          # Adds a folder to the vm for testing purposes
          add_shared_folder

          #Create a disk with the same name as the box_name
          create_disk

          add_ide_controller
          attach_isofile

          add_sata_controller
          attach_disk

          create_floppy
          add_floppy_controller
          attach_floppy

          add_ssh_nat_mapping

        end

        # http://www.virtualbox.org/manual/ch09.html#idp13716288
        def host_ip_as_seen_by_guest
          "10.0.2.2"
        end

        def start(options)
          gui_enabled=options[:nogui]==true ? false : true

          raise Veewee::Error,"Box is already running" if self.running?

          # Before we start,correct the ssh port if needed
          forward=raw.network_adapters[0].nat_driver.forwarded_ports.reject{|x| x.name!="guestssh"}.first
          guessed_port=guess_free_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
          definition.ssh_host_port=guessed_port.to_s

          unless forward.nil?
            if guessed_port!=forward.hostport
              # Remove the existing one
              forward.destroy
              env.ui.warn "Changing ssh port from #{forward.hostport} to #{guessed_port}"
              add_ssh_nat_mapping
            end
          else
              add_ssh_nat_mapping
          end

          # Once assembled we start the machine
          env.logger.info "Started the VM with GUI Enabled? #{gui_enabled}"
          if (gui_enabled)
            raw.start("gui")
          else
            raw.start("vrdp")
          end
        end

        def halt(options={})
          # If the vm is not powered off, perform a shutdown
          if (!raw.nil? && !(raw.powered_off?))
            env.ui.info "Shutting down vm #{name}"
            #We force it here, maybe vm.shutdown is cleaner
            begin
              raw.stop
              sleep 3
            rescue VirtualBox::Exceptions::InvalidVMStateException
              env.ui.error "There was problem sending the stop command because the machine is in an Invalid state"
              env.ui.error "Please verify leftovers from a previous build in your vm folder"
              exit -1
            end
          end

        end

        def build(options={})
          download_vbox_guest_additions_iso(options)
          super(options)
        end

         def download_vbox_guest_additions_iso(options)
          version="#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}"
          isofile="VBoxGuestAdditions_#{version}.iso"
          url="http://download.virtualbox.org/virtualbox/#{version}/#{isofile}"
          env.ui.info "Downloading vbox guest additions iso v #{version} - #{url}"
          download_iso(url,isofile)
        end

        # Get the IP address of the box
        def ip_address
          return "127.0.0.1"
        end

        def ssh_options
          port=definition.ssh_host_port
          if self.exists?
            forward=raw.network_adapters[0].nat_driver.forwarded_ports.reject{|x| x.name!="guestssh"}.first
            unless forward.nil?
              port=forward.hostport
            end
          end

          ssh_options={
            :user => definition.ssh_user,
            :port => port,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

        def build_info
          info=super
          info << { :filename => ".vbox_version",
                    :content => "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}" }
        end

         # Transfer information provide by the provider to the box
         #
         #
         def transfer_buildinfo(options)
           super(options)
           iso_image="VBoxGuestAdditions_#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}.iso"
           env.logger.info "About to transfer virtualbox guest additions iso to the box #{name} - #{ip_address} - #{ssh_options}"
           self.scp("#{File.join(env.config.veewee.iso_dir,iso_image)}",File.basename(iso_image))
         end



      end # End Class
    end # End Module
  end # End Module
end # End Module
