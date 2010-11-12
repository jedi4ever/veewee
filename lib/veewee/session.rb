require 'socket'
require 'net/scp'

module Veewee
  class Session
    
      attr_accessor :veewee_dir
      attr_accessor :definition_dir
      attr_accessor :template_dir
      attr_accessor :iso_dir
      attr_accessor :name
      attr_accessor :definition

    def self.setenv(env)
      @veewee_dir=env[:veewee_dir]
      @definition_dir=env[:definition_dir]
      @template_dir=env[:template_dir]
      @box_dir=env[:box_dir]
      @iso_dir=env[:iso_dir]
    end
 
    def self.declare(options)
      defaults={
        :cpu_count => '1', :memory_size=> '256', 
        :disk_size => '10140', :disk_format => 'VDI',:disk_size => '10240' ,
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-10.10-server-i386.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
        :kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 10000,:kickstart_file => "preseed.cfg",
        :ssh_login_timeout => "100",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000}
        
        @definition=defaults.merge(options)
 
    end
    
    def self.define(boxname,template_name)
      #Check if template_name exists
      #puts @veewee_dir
      if File.directory?(File.join(@template_dir,template_name))
      else
        puts "this template can not be found, use rake templates to list all templates"
      end
      if File.directory?(File.join(@definition_dir,boxname))
        puts "this definition already exists, use rake undefine['#{name}'] to remove this definition"
      else
        FileUtils.mkdir(File.join(@definition_dir,boxname))
        FileUtils.cp_r(File.join(@template_dir,template_name,'.'),File.join(@definition_dir,boxname))
        puts "template succesfully copied"
      end
    end

  
    def self.definition_exists?(boxname)
      if File.directory?(File.join(@definition_dir,boxname))
        if File.exists?(File.join(@definition_dir,boxname,'definition.rb'))
          return true
        else
           return false
        end
      else
        return false
      end
              
    end

    def self.undefine(boxname)
      name_dir=File.join(@definition_dir,boxname)
      if File.directory?(name_dir)
        #TODO: Needs to be more defensive!!
        FileUtils.rm_rf(name_dir)
      else
        puts "Can not undefine , definition #{boxname} does not exist"
        exit
      end
    end

    def self.list_templates
      puts "the following templates are available:"
      subdirs=Dir.glob("#{@template_dir}/*")
      subdirs.each do |sub|
        if File.directory?("#{sub}")
          definition=Dir.glob("#{sub}/definition.rb")
          if definition.length!=0
            name=sub.sub(/#{@template_dir}\//,'')
            puts "use rake define['<boxname>','#{name}']"
          end
        end
      end
    end

    def self.list_boxes
        puts "Not yet implemented"
    end

    def self.list_definitions
        puts "Not yet implemented"
    end

    def self.clean
        puts "Not yet implemented"
    end

    def self.remove_box(boxname)
        puts "Not yet implemented"
    end

    def self.build(boxname)
        #Now we have to load the definition (reads definition.rb)
        load_definition(boxname)

        #Command to execute locally
        @vboxcmd=determine_vboxcmd
        
        ssh_options={ :user => @definition[:ssh_user], :port => @definition[:ssh_host_port], :password => @definition[:ssh_password],
          :timeout => @definition[:ssh_timeout]}       
        
        #Suppress those annoying virtualbox messages
        suppress_messages  
        
        transaction(boxname,"initial","initial") do
        
            #Create the Virtualmachine and set all the memory and other stuff
            create_vm(boxname)

            #Create a disk with the same name as the boxname
            create_disk(boxname)
       
            #These command actually call the commandline of Virtualbox, I hope to use the virtualbox-ruby library in the future
            add_ide_controller(boxname)
            add_sata_controller(boxname)
            attach_disk(boxname)
            mount_isofile(boxname,@definition[:iso_file])
            add_ssh_nat_mapping(boxname)

            #Starting machine
            #vm.start("vrdp")
            start_vm(boxname,"gui")

            #waiting for it to boot
            sleep @definition[:boot_wait].to_i
        
            puts "sending keys"
            Veewee::Scancode.send_sequence("#{@vboxcmd}","#{boxname}",@definition[:boot_cmd_sequence])
        
            #:kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 1000,:kickstart_file => "preseed.cfg",
            Veewee::Web.wait_for_request(@definition[:kickstart_file],{:port => @definition[:kickstart_port],
                                      :host => @definition[:kickstart_ip], :timeout => @definition[:kickstart_timeout],
                                      :web_dir => File.join(@definition_dir,boxname)})
                                      
            Veewee::Ssh.when_ssh_login_works("localhost",ssh_options) do
              #snapshot initial stuff
            end
        end #initial Transaction
        
        Veewee::Ssh.when_ssh_login_works("localhost",ssh_options) do
               counter=0
               @definition[:postinstall_files].each do |postinstall_file|
                 
                 filename=File.join(@definition_dir,boxname,postinstall_file)
                 transaction(boxname,"#{counter}-#{filename}","postinstall") do
                     Veewee::Ssh.transfer_file("localhost",filename,ssh_options)
                     Veewee::Ssh.execute("localhost","echo #{@definition[:ssh_password]}|sudo -S sh #{postinstall_file}",ssh_options)
                     counter+=1
                 end
               end  
        end
        
    end

  
    def self.determine_vboxcmd
      return "VBoxManage"
    end
    
    def self.start_vm(boxname,mode)
          vm=VirtualBox::VM.find(boxname)
          vm.start(mode)
    end
    
    def self.load_definition(boxname)
      if definition_exists?(boxname)
       definition_file=File.join(@definition_dir,boxname,"definition.rb")
       begin
         require definition_file
       rescue LoadError
         puts "Error loading definition of #{boxname}"
         exit
       end    
     end
    end
    
    def self.add_ssh_nat_mapping(boxname)
      vm=VirtualBox::VM.find(boxname)
      #Map SSH Ports
      #			command => "${vboxcmd} modifyvm '${vname}' --natpf1 'guestssh,tcp,,${hostsshport},,${guestsshport}'",
      port = VirtualBox::NATForwardedPort.new
      port.name = "guestssh"
      port.guestport = @definition[:ssh_guest_port].to_i
      port.hostport = @definition[:ssh_host_port].to_i
      vm.network_adapters[0].nat_driver.forwarded_ports << port
      port.save
      vm.save  
    end
    
    def self.create_vm(boxname)
      vm=VirtualBox::VM.find(boxname)
      if !vm.nil?
        puts "box already exists"
        #vm.stop
        vm.destroy
      end

      #TODO One day ruby-virtualbox will be able to handle this creation
      #Box does not exist, we can start to create it
      command="#{@vboxcmd} createvm --name '#{boxname}' --ostype '#{@definition[:os_type_id]}' --register"    
      #Exec and system stop the execution here
      Veewee::Shell.execute("#{command}")
      vm=VirtualBox::VM.find(boxname)
      
      if (!vm.nil? && !(vm.powered_off?))
          puts "shutting down box"
          #We force it here, maybe vm.shutdown is cleaner
          vm.stop
      end     

      #Set all params we know 
      vm.memory_size=@definition[:memory_size].to_i
      vm.os_type_id=@definition[:os_type_id]
      vm.cpu_count=@definition[:cpu_count].to_i
      vm.name=boxname
      
      #setting bootorder 
      vm.boot_order[0]=:hard_disk
      vm.boot_order[1]=:dvd
      vm.boot_order[2]=:null
      vm.boot_order[3]=:null
      vm.validate
      vm.save
      
    end
    
    def self.create_disk(boxname)
      #Now check the disks
      #Maybe one day we can use the name, now we have to check location
      #disk=VirtualBox::HardDrive.find(boxname)
      disk=nil
      location=boxname+"."+@definition[:disk_format].downcase
             
      VirtualBox::HardDrive.all.each do |d|
        if !d.location.match(/#{location}/).nil?
          disk=d
        end
      end   

      if disk.nil?
        puts "creating new harddrive"
        newdisk=VirtualBox::HardDrive.new
        newdisk.format=@definition[:disk_format]
        newdisk.logical_size=@definition[:disk_size].to_i

        newdisk.location=location
        newdisk.save
        disk=newdisk             
      end
      
    end
    
    def self.add_ide_controller(boxname)
      #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
      command ="#{@vboxcmd} storagectl '#{boxname}' --name 'IDE Controller' --add ide"
       Veewee::Shell.execute("#{command}")
     end
    
    def self.add_sata_controller(boxname)
      #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
      command ="#{@vboxcmd} storagectl '#{boxname}' --name 'SATA Controller' --add sata"
      Veewee::Shell.execute("#{command}")
    end
    
    
    def self.attach_disk(boxname)
      location=boxname+"."+@definition[:disk_format].downcase
  
      #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
      command ="#{@vboxcmd} storageattach '#{boxname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
      Veewee::Shell.execute("#{command}")
    end
    
    def self.mount_isofile(boxname,isofile)
      full_iso_file=File.join(@iso_dir,isofile)
      puts "#{full_iso_file}"
      #command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
      command ="#{@vboxcmd} storageattach '#{boxname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}'"
     Veewee::Shell.execute("#{command}")
    end
    
    
    
    def self.suppress_messages
      #Setting this annoying messages to register
      VirtualBox::ExtraData.global["GUI/RegistrationData"]="triesLeft=0"
      VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, 2009-09-20"
      VirtualBox::ExtraData.global["GUI/SuppressMessages"]="confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff"
      VirtualBox::ExtraData.global["GUI/UpdateCheckCount"]="60"
      update_date=Time.now+86400
      VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, #{update_date.year}-#{update_date.month}-#{update_date.day}, stable"
      
      VirtualBox::ExtraData.global.save
    end

    def self.local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end
    
    def self.transaction(boxname,name,checksum_params, &block)
      if checksum_params=="initial2"
        puts "skipping"
      else
        yield
      end
    end
    
    def transaction2(boxname,name,checksum_params, &block)
      
       if @provider.snapshot_exists(@vmname,name+"-"+options[:checksum])
          @provider.load_snapshot_vmachine(@vmname,name+"-"+options[:checksum])
        else
          if @provider.snapshot_version_exists(@vmname,name)
            @provider.rollback_snapshot(@vmname,name)
            #rollback to snapshot prior to this one
          end
          yield
          @provider.create_snapshot_vmachine(@vmname,name+"-"+options[:checksum])
        end
      #end
    end

  end
end