module Veewee
  module Builder
    module Virtualbox

      def build(build_options={})
        defaults={  "force" => false, "format" => "vagrant", "nogui" => false }
        options = defaults.merge(build_options)

        #Suppress those annoying virtualbox messages
        suppress_messages  

        #Check iso file
        verify_iso(@definition.iso_file)

        vm=VirtualBox::VM.find(@box_name)

        # Discarding save state
        if (!vm.nil? && (vm.saved?))
          puts "Removing save state"
          vm.discard_state
          vm.reload
        end

        # If the box is running shut it down
        if (!vm.nil? && !(vm.powered_off?))
          puts "Shutting down vm #{@box_name}"
          #We force it here, maybe vm.shutdown is cleaner
          begin

            vm.stop
          rescue VirtualBox::Exceptions::InvalidVMStateException
            puts "There was problem sending the stop command because the machine is in an Invalid state"
            puts "Please verify leftovers from a previous build in your vm folder"
          end
          sleep 3
        end


        if (options["force"]==false)
          puts "The box is already there, we can't destroy it"
          exit
        else    
          puts "Forcing build by destroying #{@box_name} machine"
          destroy
        end

        if Veewee::Util::Tcp.is_port_open?("localhost", @definition.ssh_host_port)
          puts "Hmm, the port #{@definition.ssh_host_port} is open. And we shut down?"
          exit
        end


        #Create the Virtualmachine and set all the memory and other stuff
        assemble

        #Starting machine
        if (options["nogui"]==true)
          start_vm("vrdp")
        else
          start_vm("gui")
        end

        #waiting for it to boot
        puts "Waiting for the machine to boot"
        sleep @definition.boot_wait.to_i

        send_sequence(@definition.boot_cmd_sequence)

        handle_kickstart
        transfer_buildinfo_file

        handle_postinstall

        puts "#{@box_name} was build succesfully. "
        puts ""
        puts "Now you can: "
        puts "- verify your box by running              : vagrant basebox validate #{@box_name}"
        puts "- export your vm to a .box fileby running : vagrant basebox export   #{@box_name}"

      end


    end #Module
  end #Module
end #Module