module Veewee
  module Builder
    module Virtualbox

      def build(build_options={})

        # Handle the options passed and set some sensible defaults
        defaults={  "force" => false, "format" => "vagrant", "nogui" => false }
        options = defaults.merge(build_options)

        #Suppress those annoying virtualbox messages
        suppress_messages

        # Check the iso file we need to build the box
        verify_iso(@definition.iso_file)

        # Check if the box already exists
        vm=VirtualBox::VM.find(@box_name)
        box_exists=!vm.nil?

        # If the box exists, check if the force flag was passed before continuing
        if box_exists

          # If no force flag was passed
          if (options["force"]==false)
            puts "The box is already there, we can't destroy it"
            exit
          else

            # If it has a save state,remove that first
            if vm.saved?
              puts "Removing save state"
              vm.discard_state
              vm.reload
            end

            # If the vm is not powered off, perform a shutdown
            if (!vm.nil? && !(vm.powered_off?))
              puts "Shutting down vm #{@box_name}"
              #We force it here, maybe vm.shutdown is cleaner
              begin
                vm.stop
                sleep 3
              rescue VirtualBox::Exceptions::InvalidVMStateException
                puts "There was problem sending the stop command because the machine is in an Invalid state"
                puts "Please verify leftovers from a previous build in your vm folder"
              end
            end

            puts "Forcing build by destroying #{@box_name} machine"
            destroy
          end
        end

        # By now the machine if it existed, should have been shutdown
        # The last thing to check is if the power we are supposed to ssh to, is still open

        if Veewee::Util::Tcp.is_port_open?("localhost", @definition.ssh_host_port)
          puts "Hmm, the port #{@definition.ssh_host_port} is open. And we shut down?"
          exit
        end

        # Everything indicates we can new build a new vm, 
        # time to create the Virtualmachine and set all the memory and other stuff
        assemble

        # Once assembled we start the machine
        if (options["nogui"]==true)
          start_vm("vrdp")
        else
          start_vm("gui")
        end

        # Now we wait the number of seconds specified after the boot
        puts "Waiting for the machine to boot"
        sleep @definition.boot_wait.to_i

        # We've waited long enough, time to send the boot_cmd sequence to the console
        send_sequence(@definition.boot_cmd_sequence)

        # Bootsequence has been send (if there was one)
        # And now we start up the webserver for handling the kickstart and 
        # wait for the file to be fetched
        handle_kickstart

        # After the kickstart, we wait for ssh to become available and 
        # once we can login , we transfer some info to the vm about our environment
        transfer_buildinfo_file

        # Now we can run all the post installs scripts
        handle_postinstall

        # w00t, we have succesfully reach this point
        # so we let user know , the vm is ready to be exported

        puts "#{@box_name} was build succesfully. "
        puts ""
        puts "Now you can: "
        puts "- verify your box by running              : vagrant basebox validate #{@box_name}"
        puts "- export your vm to a .box fileby running : vagrant basebox export   #{@box_name}"

      end


    end #Module
  end #Module
end #Module
