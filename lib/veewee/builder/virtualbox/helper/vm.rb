module Veewee
  module Builder
    module Virtualbox

      def verify_ostype

        #Verifying the os.id with the :os_type_id specified
        matchfound=false
        VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
          if @definition.os_type_id == os.id
            matchfound=true
          end
        }
        unless matchfound
          puts "The ostype: #{@definition.os_type_id} is not available in your Virtualbox version"
          exit
        end

      end

      # This function creates a basic vm
      def create_vm
        verify_ostype

        vm=VirtualBox::VM.find(@box_name)

        if (!vm.nil? && !(vm.powered_off?))
          puts "shutting down box"
          #We force it here, maybe vm.shutdown is cleaner
          vm.stop
        end

        if !vm.nil?
          puts "Box already exists"
          #vm.stop
          #vm.destroy
        else
          #TODO One day ruby-virtualbox will be able to handle this creation
          #Box does not exist, we can start to create it

          command="#{@vboxcmd} createvm --name '#{@box_name}' --ostype '#{@definition.os_type_id}' --register"

          #Exec and system stop the execution here
          Veewee::Util::Shell.execute("#{command}")

          # Modify the vm to enable or disable hw virtualization extensions
          vm_flags=%w{pagefusion acpi ioapic pae hpet hwvirtex hwvirtexcl nestedpaging largepages vtxvpid synthxcpu rtcuseutc}

          vm_flags.each do |vm_flag|
            if @definition.instance_variable_defined?("@#{vm_flag}")
              #vm_flag_value=@definition.instance_variable_get(vm_flag.to_sym)

              vm_flag_value=@definition.instance_variable_get("@#{vm_flag}")
              puts "Setting VM Flag #{vm_flag} to #{vm_flag_value}"
              command="#{@vboxcmd} modifyvm #{@box_name} --#{vm_flag.to_s} #{vm_flag_value}"
              Veewee::Util::Shell.execute("#{command}")
            end
          end


        end

        vm=VirtualBox::VM.find(@box_name)
        if vm.nil?
          puts "we tried to create a box or a box was here before"
          puts "but now it's gone"
          exit
        end

        #Set all params we know
        vm.memory_size=@definition.memory_size.to_i
        vm.os_type_id=@definition.os_type_id
        vm.cpu_count=@definition.cpu_count.to_i
        vm.name=@box_name

        puts "Creating vm #{vm.name} : #{vm.memory_size}M - #{vm.cpu_count} CPU - #{vm.os_type_id}"
        #setting bootorder
        vm.boot_order[0]=:hard_disk
        vm.boot_order[1]=:dvd
        vm.boot_order[2]=:null
        vm.boot_order[3]=:null
        vm.validate
        vm.save


      end


      def start_vm(mode)
        vm=VirtualBox::VM.find(@box_name)
        vm.start(mode)
      end

    end
  end
end


