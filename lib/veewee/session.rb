require 'digest/md5'
require 'socket'
require 'net/scp'
require 'pp'

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
      @tmp_dir=env[:tmp_dir]
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
        :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
        :shutdown_cmd => "shutdown -H",
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
        puts "this definition already exists, use rake undefine['#{boxname}'] to remove this definition"
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

    def self.verify_iso(filename)
      if File.exists?(File.join(@iso_dir,filename))
        puts "isofile #{filename} is available"
      else
        full_path=File.join(@iso_dir,filename)
        path1=Pathname.new(full_path)
        path2=Pathname.new(Dir.pwd)
        rel_path=path1.relative_path_from(path2).to_s
        
        puts
        puts "Isofile is not found. The definition suggested the following URL to download:"
        puts "-url: #{@definition[:iso_src]}"
        puts "-md5: #{@definition[:iso_md5]}"
        puts ""
        puts "type:"
        puts "curl -C - -L '#{@definition[:iso_src]}' -o '#{rel_path}'"
        puts "md5 '#{rel_path}' "
        puts 
        exit
      end
  
    end

    def self.export_box(boxname)
      #Now we have to load the definition (reads definition.rb)
      load_definition(boxname)
      
      Veewee::Export.vagrant(boxname,@box_dir,@definition)
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
        
        verify_iso(@definition[:iso_file])
        
        checksums=calculate_checksums(@definition,boxname)

   
        
        transaction(boxname,"0-initial",checksums) do
        
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
                    
              #Transfer version of Virtualbox to $HOME/.vbox_version
              versionfile=File.join(@tmp_dir,".vbox_version")    
              File.open(versionfile, 'w') {|f| f.write("#{VirtualBox::Global.global.lib.virtualbox.version}") }
              Veewee::Ssh.transfer_file("localhost",versionfile,ssh_options)
              
               counter=1
               @definition[:postinstall_files].each do |postinstall_file|
                 
                 filename=File.join(@definition_dir,boxname,postinstall_file)   
      
                 transaction(boxname,"#{counter}-#{postinstall_file}",checksums) do
                   
                    Veewee::Ssh.transfer_file("localhost",filename,ssh_options)
                    command=@definition[:sudo_cmd]
                    command.gsub!(/%p/,"#{@definition[:ssh_password]}")
                    command.gsub!(/%u/,"#{@definition[:ssh_user]}")
                    command.gsub!(/%f/,"#{postinstall_file}")

                    Veewee::Ssh.execute("localhost","#{command}",ssh_options)
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
        #vm.destroy
      end

      #Verifying the os.id with the :os_type_id specified
      matchfound=false
      VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
        if @definition[:os_type_id] == os.id
          matchfound=true
        end
      }
      unless matchfound
        puts "The ostype: #{@definition[:os_type_id]} is not available in your Virtualbox version"
        exit
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
      location=boxname+"."+@definition[:disk_format].downcase
      
      found=false       
      VirtualBox::HardDrive.all.each do |d|
        if !d.location.match(/#{location}/).nil?
          found=true
          break
        end
      end   

      if !found
        puts "creating new harddrive"
        newdisk=VirtualBox::HardDrive.new
        newdisk.format=@definition[:disk_format]
        newdisk.logical_size=@definition[:disk_size].to_i

        newdisk.location=location
        newdisk.save
           
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
    
    def self.list_ostypes
      puts
      puts "Available os types:"
      VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
        puts "#{os.id}: #{os.description}"
      }
      
      puts 
      
    end
    
    
    def self.calculate_checksums(definition,boxname)

        #TODO: get rid of definitiondir and so one
        initial=definition.clone

        keys=[:postinstall_files,:sudo_cmd,:postinstall_timeout]
        keys.each do |key|
          initial.delete(key)
        end

        checksums=Array.new
        checksums << Digest::MD5.hexdigest(initial.to_s)

        postinstall_files=definition[:postinstall_files]
        unless postinstall_files.nil?
          for filename in postinstall_files
            begin
            full_filename=File.join(@definition_dir,boxname,filename)   

            checksums << Digest::MD5.hexdigest(File.read(full_filename))
            rescue
              puts "Error reading postinstall file #{filename} - checksum"
              exit
            end
          end
        end

        pp checksums
        return checksums

      end

    
      def self.transaction(boxname,step_name,checksums,&block)

        current_step_nr=step_name.split("-")[0].to_i

        vm=VirtualBox::VM.find(boxname)  
        snapnames=Array.new

        #If vm exists , look for snapshots
        if !vm.nil?
          start_snapshot=vm.root_snapshot
          snapshot=start_snapshot
          counter=0

          while (snapshot!=nil)
        	  #puts "#{counter}:#{snapshot.name}"
         	  snapnames[counter]=snapshot.name
            counter=counter+1  
            snapshot=snapshot.children[0]
          end 
        end

        #find the last snapshot matching the state
        counter=[snapnames.length, checksums.length].min-1
        last_good_state=counter
        for c in 0..counter do
            #puts "#{c}- #{snapnames[c]} - #{checksums[c]}"
            if snapnames[c]!=checksums[c]
      #        puts "we found a bad state"
              last_good_state=c-1
              break
            end  
        end
        puts "Last good state: #{last_good_state}"

        if (current_step_nr < last_good_state)
            puts "fast forwarding #{step_name}"
            return
        end

        if (current_step_nr == last_good_state)
            if vm.running?
              vm.stop
            end

            #invalidate later snapshots
            #puts "remove old snapshots"

            for s in (last_good_state+1)..(snapnames.length-1)
              puts "removing snapname #{snapnames[s]}"
              snapshot=vm.find_snapshot(snapnames[s])
              snapshot.destroy
              #puts snapshot
            end

            vm.reload
            puts "action load #{step_name}"
            #TODO:Restore snapshot!!!
            vm.start

        end

        if (current_step_nr > last_good_state)

          if (last_good_state==-1)
            #no initial snapshot is found, clean machine!
            vm=VirtualBox::VM.find(boxname) 
 
            if !vm.nil?
              if vm.running?
                puts "stopping machine"
                vm.stop
                while vm.running?
                  sleep 1
                end
              end
              
              #detaching cdroms
              vm.medium_attachments.each do |m|
                if m.type==:dvd
                  puts "detaching dvd"
                  m.detach
                end
              end
              
              vm.reload
              puts "destroying machine+disks"
              #:destroy_medium => :delete,  will delete machine + all media attachments
              vm.destroy(:destroy_medium => :delete)
              #vm.destroy(:destroy_image => true)
              
              #if the disk was not attached when the machine was destroyed we also need to delete the disk
              location=boxname+"."+@definition[:disk_format].downcase
              found=false       
              VirtualBox::HardDrive.all.each do |d|
                if !d.location.match(/#{location}/).nil?
                  d.destroy(true)
                  break
                end
              end     
            end
              
          end

          puts "(re-)executing step #{step_name}"
          
         
          yield
          puts "seeking #{boxname}"
          #Need to look it up again because if it was an initial load
          vm=VirtualBox::VM.find(boxname) 
          puts "about to snapshot #{vm}"
          #take snapshot after succesful execution
          vm.take_snapshot(step_name,"snapshot taken by veewee")

        end   

        #pp snapnames
      end
      

  end #End Class
end #End Module