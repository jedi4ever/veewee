module Veewee
  module Builder
    module Vmfusion


      def build(build_options={})
        defaults= {  "force" => false, "nogui" => false }
        options=defaults.merge(build_options)
        
        if is_running?
          if options["force"]==true
            stop_vm
            destroy
          else
            puts "Machine is running, we can't build it, unless you have the --force option"
          end
          
        end

        #Check iso file
        verify_iso(@definition.iso_file)

        # Check if the IP address/Port is running
        unless ip_address.nil?
          if Veewee::Util::Tcp.is_port_open?(ip_address, @definition.ssh_host_port)
            puts "Hmm, the port #{@definition.ssh_host_port} is open. And we shut down?"
            exit
          end
        end

        # Assemble the Virtualmachine and set all the memory and other stuff
        assemble

        #Starting machine
        if (options["nogui"]==true)
          start_vm("nogui")
        else
          start_vm("gui")
        end

        #waiting for it to boot
        puts "Waiting for the machine to boot"
        sleep @definition.boot_wait.to_i

        # Sending keystrokes
        send_sequence(@definition.boot_cmd_sequence)

        handle_kickstart
        transfer_buildinfo_file

        handle_postinstall

        puts "#{@box_name} was build succesfully. "

      end



    end #Module
  end #Module
end #Module