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
require 'veewee/builder/virtualbox/helper/path'

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

      def create(definition)
         command="#{@vboxcmd} createvm --name '#{@box_name}' --ostype '#{definition.os_type_id}' --register"

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
        vm.memory_size=definition.memory_size.to_i
        vm.os_type_id=definition.os_type_id
        vm.cpu_count=definition.cpu_count.to_i
        vm.name=name

        puts "Creating vm #{vm.name} : #{vm.memory_size}M - #{vm.cpu_count} CPU - #{vm.os_type_id}"
        #setting bootorder
        vm.boot_order[0]=:hard_disk
        vm.boot_order[1]=:dvd
        vm.boot_order[2]=:null
        vm.boot_order[3]=:null
        vm.validate
        vm.save
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
