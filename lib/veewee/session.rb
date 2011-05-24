require 'digest/md5'
require 'socket'
require 'net/scp'
require 'pp'
require 'open-uri'
require 'progressbar'
require 'highline/import'
require 'tempfile'


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
      @validation_dir=env[:validation_dir]
      @box_dir=env[:box_dir]
      @iso_dir=env[:iso_dir]
      @tmp_dir=env[:tmp_dir]
    end
 
    def self.declare(options)
      defaults={
        :cpu_count => '1', :memory_size=> '256', 
        :disk_size => '10240', :disk_format => 'VDI', :hostiocache => 'off' ,
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-10.10-server-i386.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
        :kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 10000,
        :ssh_login_timeout => "100",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
        :shutdown_cmd => "shutdown -h now",
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000}
        
        @definition=defaults.merge(options)
 
    end
    
    def self.define(boxname,template_name,options = {})
      #Check if template_name exists
      
      options = {  "force" => false, "format" => "vagrant" }.merge(options)
      
      if File.directory?(File.join(@template_dir,template_name))
      else
        puts "This template can not be found, use vagrant basebox templates to list all templates"
        exit
      end
      if !File.exists?(@definition_dir)
        FileUtils.mkdir(@definition_dir)
      end
      
      if File.directory?(File.join(@definition_dir,boxname))
        if !options["force"]
          puts "The definition for #{boxname} already exists. Use --force to overwrite"
          exit
        end
      else
        FileUtils.mkdir(File.join(@definition_dir,boxname))
      end
      FileUtils.cp_r(File.join(@template_dir,template_name,'.'),File.join(@definition_dir,boxname))
      puts "The basebox '#{boxname}' has been succesfully created from the template ''#{template_name}'"
      puts "You can now edit the definition files stored in definitions/#{boxname}"
      puts "or build the box with:"
      if (options["format"]=='vagrant') 
         puts "vagrant basebox build '#{boxname}'"
       end
       if (options["format"]=='veewee')
         puts "veewee  build '#{boxname}'"
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
        puts "Removing definition #{boxname}"
        FileUtils.rm_rf(name_dir)
      else
        puts "Can not undefine , definition #{boxname} does not exist"
        exit
      end
    end

    def self.list_templates( options = { :format => 'vagrant'})
      puts "The following templates are available:"
      subdirs=Dir.glob("#{@template_dir}/*")
      subdirs.each do |sub|
        if File.directory?("#{sub}")
          definition=Dir.glob("#{sub}/definition.rb")
          if definition.length!=0
            name=sub.sub(/#{@template_dir}\//,'')
            if (options[:format]=='vagrant') 
              puts "vagrant basebox define '<boxname>' '#{name}'"
            end
            if (options[:format]=='veewee')
              puts "veewee define '<boxname>' '#{name}'"
            end
          end
        end
      end
    end

    def self.list_boxes
        puts "Not yet implemented"
    end

    def self.list_definitions
        puts "The following defined baseboxes exist:"
        subdirs=Dir.glob("#{@definition_dir}/*")
        subdirs.each do |sub|
          puts "- "+File.basename(sub)
        end
    end

    def self.clean
        puts "Not yet implemented"
    end

    def self.verify_iso(filename,autodownload = false)
      if File.exists?(File.join(@iso_dir,filename))
        puts 
        puts "Verifying the isofile #{filename} is ok."
      else

        full_path=File.join(@iso_dir,filename)
        path1=Pathname.new(full_path)
        path2=Pathname.new(Dir.pwd)
        rel_path=path1.relative_path_from(path2).to_s
        
        puts
        puts "We did not find an isofile in <currentdir>/iso. \n\nThe definition provided the following download information:"
        unless "#{@definition[:iso_src]}"==""
          puts "- Download url: #{@definition[:iso_src]}"
        end
        puts "- Md5 Checksum: #{@definition[:iso_md5]}"
        puts "#{@definition[:iso_download_instructions]}"
        puts
        
        if @definition[:iso_src] == ""
          puts "Please follow the instructions above:"
          puts "- to get the ISO"
          puts" - put it in <currentdir>/iso"
          puts "- then re-run the command"
          puts
          exit
        else
        
        question=ask("Download? (Yes/No)") {|q| q.default="No"}
        if question.downcase == "yes"
          if !File.exists?(@iso_dir)
            puts "Creating an iso directory"
            FileUtils.mkdir(@iso_dir)
          end
          
          download_progress(@definition[:iso_src],full_path)
        else
          puts "You have choosen for manual download: "
          puts "curl -C - -L '#{@definition[:iso_src]}' -o '#{rel_path}'"
          puts "md5 '#{rel_path}' "
          puts 
          exit
        end
        
      end
      end
  
    end

    def self.export_box(boxname)
      #Now we have to load the definition (reads definition.rb)
      load_definition(boxname)
      
      Veewee::Export.vagrant(boxname,@box_dir,@definition)
      #vagrant removes the mapping
      #we need to restore it in order to be able to login again
      add_ssh_nat_mapping(boxname)
      
    end
    
    def self.remove_box(boxname)
        puts "Not yet implemented"
    end

    def self.build(boxname,options)
      
        options = {  "force" => false, "format" => "vagrant", "nogui" => false }.merge(options)
      
        #Now we have to load the definition (reads definition.rb)
        load_definition(boxname)

        #Command to execute locally
        @vboxcmd=determine_vboxcmd
        
        ssh_options={ :user => @definition[:ssh_user], :port => @definition[:ssh_host_port], :password => @definition[:ssh_password],
          :timeout => @definition[:ssh_timeout]}       
        
        #Suppress those annoying virtualbox messages
        suppress_messages  
        
        
        vm=VirtualBox::VM.find(boxname)

        if (!vm.nil? && (vm.saved?))
          puts "Removing save state"
          vm.discard_state
          vm.reload
        end
        
        if (!vm.nil? && !(vm.powered_off?))
            puts "Shutting down vm #{boxname}"
            #We force it here, maybe vm.shutdown is cleaner
            begin

                vm.stop
            rescue VirtualBox::Exceptions::InvalidVMStateException
              puts "There was problem sending the stop command because the machine is in an Invalid state"
              puts "Please verify leftovers from a previous build in your vm folder"
              exit
            end
            sleep 3
        end
        
        
        verify_iso(@definition[:iso_file])
        
        if (options["force"]==false)
        else    
          puts "Forcing build by destroying #{boxname} machine"
          destroy_vm(boxname)
        end
        
        if Veewee::Utils.is_port_open?("localhost", @definition[:ssh_host_port])
          puts "Hmm, the port #{@definition[:ssh_host_port]} is open. And we shut down?"
          exit
        end
        
        checksums=calculate_checksums(@definition,boxname)
        
        transaction(boxname,"0-initial-#{checksums[0]}",checksums) do
        
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

            if (options["nogui"]==true)
              start_vm(boxname,"vrdp")
            else
              start_vm(boxname,"gui")
            end
            
            #waiting for it to boot
            puts "Waiting for the machine to boot"
            sleep @definition[:boot_wait].to_i
        
            Veewee::Scancode.send_sequence("#{@vboxcmd}","#{boxname}",@definition[:boot_cmd_sequence],@definition[:kickstart_port])
        
            kickstartfile=@definition[:kickstart_file]
            if kickstartfile.nil? || kickstartfile.length == 0
                puts "Skipping webserver as no kickstartfile was specified"
            else
                puts "Starting a webserver on port #{@definition[:kickstart_port]}"
                #:kickstart_port => "7122", :kickstart_ip => self.local_ip, :kickstart_timeout => 1000,:kickstart_file => "preseed.cfg",
		if kickstartfile.is_a? String
			Veewee::Web.wait_for_request(kickstartfile,{:port => @definition[:kickstart_port],
                                          :host => @definition[:kickstart_ip], :timeout => @definition[:kickstart_timeout],
                                          :web_dir => File.join(@definition_dir,boxname)})
		end 
		if kickstartfile.is_a? Array
			kickstartfiles=kickstartfile
			kickstartfiles.each do |kickfile|
				Veewee::Web.wait_for_request(kickfile,{:port => @definition[:kickstart_port],
                                          :host => @definition[:kickstart_ip], :timeout => @definition[:kickstart_timeout],
                                          :web_dir => File.join(@definition_dir,boxname)})
			end
		end
            end
                                      
                                      
            Veewee::Ssh.when_ssh_login_works("localhost",ssh_options) do
              #Transfer version of Virtualbox to $HOME/.vbox_version            
              versionfile=Tempfile.open("vbox.version")
              versionfile.puts "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}"
              versionfile.rewind
              begin
                Veewee::Ssh.transfer_file("localhost",versionfile.path,".vbox_version", ssh_options)
              rescue RuntimeError
                puts "error transfering file, possible not enough permissions to write?"
                exit
              end
              puts ""
              versionfile.close
              versionfile.delete
            end
        end #initial Transaction
 
                 
               counter=1
               @definition[:postinstall_files].each do |postinstall_file|
     
                 
                 filename=File.join(@definition_dir,boxname,postinstall_file)   
      
                 transaction(boxname,"#{counter}-#{postinstall_file}-#{checksums[counter]}",checksums) do
                   
                   Veewee::Ssh.when_ssh_login_works("localhost",ssh_options) do
                    begin
                      Veewee::Ssh.transfer_file("localhost",filename,File.basename(filename),ssh_options)
                    rescue RuntimeError
                      puts "error transfering file, possible not enough permissions to write?"
                      exit
                    end
                    command=@definition[:sudo_cmd]
                    newcommand=command.gsub(/%p/,"#{@definition[:ssh_password]}")
                    newcommand.gsub!(/%u/,"#{@definition[:ssh_user]}")
                    newcommand.gsub!(/%f/,"#{postinstall_file}")
		    puts "***#{newcommand}"
                    Veewee::Ssh.execute("localhost","#{newcommand}",ssh_options)
                    end
                    
                 end
                 counter+=1
                 
               end  
     
          puts "#{boxname} was build succesfully. "
          puts ""
          puts "Now you can: "
          puts "- verify your box by running              : vagrant basebox validate #{boxname}"
          puts "- export your vm to a .box fileby running : vagrant basebox export   #{boxname}"
        
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
      else
        puts "Error: definition for basebox '#{boxname}' does not exist."
        list_definitions
        exit
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
    
    def self.destroy_vm(boxname)
      
      load_definition(boxname)
      @vboxcmd=determine_vboxcmd      
      #:destroy_medium => :delete,  will delete machine + all media attachments
      #vm.destroy(:destroy_medium => :delete)
      ##vm.destroy(:destroy_image => true)
      
      #VBoxManage unregistervm "test-machine" --delete
      #because the destroy does remove the .vbox file on 4.0.x
      #PDB
      #vm.destroy()
      
      
      
      vm=VirtualBox::VM.find(boxname)

      if (!vm.nil? && !(vm.powered_off?))
          puts "Shutting down vm #{boxname}"
          #We force it here, maybe vm.shutdown is cleaner
          begin
            vm.stop
          rescue VirtualBox::Exceptions::InvalidVMStateException
            puts "There was problem sending the stop command because the machine is in an Invalid state"
            puts "Please verify leftovers from a previous build in your vm folder"
            exit
          end
          sleep 3
      end     

      
      command="#{@vboxcmd} unregistervm  '#{boxname}' --delete"    
      puts command
      puts "Deleting vm #{boxname}"
      
      #Exec and system stop the execution here
      Veewee::Shell.execute("#{command}")
      sleep 1
      
      #if the disk was not attached when the machine was destroyed we also need to delete the disk
      location=boxname+"."+@definition[:disk_format].downcase
      found=false       
      VirtualBox::HardDrive.all.each do |d|
        if d.location.match(/#{location}/)
          
          if File.exists?(d.location) 
            command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
          else
            command="#{@vboxcmd} closemedium disk '#{d.location}'"        
          end
          
          #command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
          puts "Deleting disk #{d.location}"
          puts "#{command}"

          Veewee::Shell.execute("#{command}") 
          
          if File.exists?(d.location) 
            puts "We tried to delete the disk file via virtualbox '#{d.location} but failed"
            puts "Removing it manually"
            FileUtils.rm(d.location)
            exit
          end 
          #v.3
          #d.destroy(true)
          break
        end
      end     
    end
    
    def self.create_vm(boxname,force=false)
      
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


      vm=VirtualBox::VM.find(boxname)

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

        command="#{@vboxcmd} createvm --name '#{boxname}' --ostype '#{@definition[:os_type_id]}' --register"

        #Exec and system stop the execution here
        Veewee::Shell.execute("#{command}")

        # Modify the vm to enable or disable hw virtualization extensions
        vm_flags=%w{pagefusion acpi ioapic pae hpet hwvirtex hwvirtexcl nestedpaging largepages vtxvpid synthxcpu rtcuseutc}
        
        vm_flags.each do |vm_flag|
          unless @definition[vm_flag.to_sym].nil?
            puts "Setting VM Flag #{vm_flag} to #{@definition[vm_flag.to_sym]}"
            command="#{@vboxcmd} modifyvm #{boxname} --#{vm_flag.to_s} #{@definition[vm_flag.to_sym]}"
            Veewee::Shell.execute("#{command}")
          end
        end

        # Todo Check for java
        # Todo check output of commands
        
        # Check for floppy
        unless @definition[:floppy_files].nil?
            require 'tmpdir'
            temp_dir=Dir.tmpdir
            @definition[:floppy_files].each do |filename|
              full_filename=full_filename=File.join(@definition_dir,boxname,filename)
              FileUtils.cp("#{full_filename}","#{temp_dir}")
            end
            javacode_dir=File.expand_path(File.join(__FILE__,'..','..','java'))
            floppy_file=File.join(@definition_dir,boxname,"virtualfloppy.vfd")
            command="java -jar #{javacode_dir}/dir2floppy.jar '#{temp_dir}' '#{floppy_file}'"
            puts "#{command}"
            Veewee::Shell.execute("#{command}")
            
            # Create floppy controller
            command="#{@vboxcmd} storagectl '#{boxname}' --name 'Floppy Controller' --add floppy"
            puts "#{command}"
            Veewee::Shell.execute("#{command}")
            
            # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
            command="#{@vboxcmd} storageattach '#{boxname}' --storagectl 'Floppy Controller' --port 0 --device 0 --type fdd --medium '#{floppy_file}'"
            puts "#{command}"
            Veewee::Shell.execute("#{command}")   
            
        end
        
        
        #Exec and system stop the execution here
        Veewee::Shell.execute("#{command}")

        command="#{@vboxcmd} sharedfolder add  '#{boxname}' --name 'veewee-validation' --hostpath '#{File.expand_path(@validation_dir)}' --automount"

        Veewee::Shell.execute("#{command}")

      end

      vm=VirtualBox::VM.find(boxname)
      if vm.nil?
        puts "we tried to create a box or a box was here before"
        puts "but now it's gone"
        exit
      end
      
      #Set all params we know 
      vm.memory_size=@definition[:memory_size].to_i
      vm.os_type_id=@definition[:os_type_id]
      vm.cpu_count=@definition[:cpu_count].to_i
      vm.name=boxname

      puts "Creating vm #{vm.name} : #{vm.memory_size}M - #{vm.cpu_count} CPU - #{vm.os_type_id}"
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

      @vboxcmd=determine_vboxcmd
      
      if !found
        puts "Creating new harddrive of size #{@definition[:disk_size].to_i} "
        
        #newdisk=VirtualBox::HardDrive.new
        #newdisk.format=@definition[:disk_format]
        #newdisk.logical_size=@definition[:disk_size].to_i

        #newdisk.location=location
        ##PDB: again problems with the virtualbox GEM
	      ##VirtualBox::Global.global.max_vdi_size=1000000
        #newdisk.save
        
        command="#{@vboxcmd}  list  systemproperties|grep '^Default machine'|cut -d ':' -f 2|sed -e 's/^[ ]*//'"
        results=IO.popen("#{command}")
        place=results.gets.chop
        results.close
         
        command ="#{@vboxcmd} createhd --filename '#{place}/#{boxname}/#{boxname}.#{@definition[:disk_format].downcase}' --size '#{@definition[:disk_size].to_i}' --format #{@definition[:disk_format].downcase} > /dev/null"
        puts "#{command}"
        Veewee::Shell.execute("#{command}")
                   
      end
      
    end
    
    def self.add_ide_controller(boxname)
      #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
      command ="#{@vboxcmd} storagectl '#{boxname}' --name 'IDE Controller' --add ide"
       Veewee::Shell.execute("#{command}")
     end
    
    def self.add_sata_controller(boxname)
      #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
      command ="#{@vboxcmd} storagectl '#{boxname}' --name 'SATA Controller' --add sata --hostiocache #{@definition[:hostiocache]}"
      Veewee::Shell.execute("#{command}")
    end
    
    
    def self.attach_disk(boxname)
      location=boxname+"."+@definition[:disk_format].downcase
    
      @vboxcmd=determine_vboxcmd
      
      command="#{@vboxcmd}  list  systemproperties|grep '^Default machine'|cut -d ':' -f 2|sed -e 's/^[ ]*//'"
      results=IO.popen("#{command}")
      place=results.gets.chop
      results.close

      location="#{place}/#{boxname}/"+location
      puts "Attaching disk: #{location}"
      
      #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
      command ="#{@vboxcmd} storageattach '#{boxname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
      Veewee::Shell.execute("#{command}")

    end
    
    def self.mount_isofile(boxname,isofile)
      full_iso_file=File.join(@iso_dir,isofile)
      puts "Mounting cdrom: #{full_iso_file}"
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
    
    def self.validate_box(boxname)
      require 'cucumber'

      require 'cucumber/rspec/disable_option_parser'
      require 'cucumber/cli/main'


      feature_path=File.join(File.dirname(__FILE__),"..","..","validation","vagrant.feature")

      features=Array.new
      features[0]=feature_path


      begin
        # The dup is to keep ARGV intact, so that tools like ruby-debug can respawn.
        failure = Cucumber::Cli::Main.execute(features.dup)
        Kernel.exit(failure ? 1 : 0)
      rescue SystemExit => e
        Kernel.exit(e.status)
      rescue Exception => e
        STDERR.puts("#{e.message} (#{e.class})")
        STDERR.puts(e.backtrace.join("\n"))
        Kernel.exit(1)
      end

    end
    
    def self.list_ostypes
      puts
      puts "Available os types:"
      VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
        puts "#{os.id}: #{os.description}"
      }      
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

        return checksums

      end

      def self.download_progress(url,localfile)
        pbar = nil
        URI.parse(url).open(
            :content_length_proc => lambda {|t|
              if t && 0 < t
                pbar = ProgressBar.new("Fetching file", t)
                pbar.file_transfer_mode
              end
            },
            :progress_proc => lambda {|s|
              pbar.set s if pbar
            }) { |src|
              open("#{localfile}","wb") { |dst|
                dst.write(src.read)
              }
            }
         
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
            if !snapnames[c].match("#{c}.*-#{checksums[c]}")
      #        puts "we found a bad state"
              last_good_state=c-1
              break
            end  
        end
        #puts "Last good state: #{last_good_state}"

        if (current_step_nr < last_good_state)
            #puts "fast forwarding #{step_name}"
            return
        end

        #puts "Current step: #{current_step_nr}"
        if (current_step_nr == last_good_state)
            if vm.running?
              vm.stop
            end

            #invalidate later snapshots
            #puts "remove old snapshots"

            for s in (last_good_state+1)..(snapnames.length-1)
              puts "Removing step [#{s}] snapshot as it is no more valid"
              snapshot=vm.find_snapshot(snapnames[s])
              snapshot.destroy
              #puts snapshot
            end

            vm.reload
            puts "Loading step #{current_step_nr} snapshots as it has not changed"
            sleep 2
            goodsnap=vm.find_snapshot(snapnames[last_good_state])
            goodsnap.restore
            sleep 2
            #TODO:Restore snapshot!!!
            vm.start
            sleep 4
            puts "Starting machine"
        end

        #puts "last good state #{last_good_state}"

        
        if (current_step_nr > last_good_state)

          if (last_good_state==-1)
            #no initial snapshot is found, clean machine!
            vm=VirtualBox::VM.find(boxname) 
 
            if !vm.nil?
              if vm.running?
                puts "Stopping machine"
                vm.stop
                while vm.running?
                  sleep 1
                end
              end
              
              #detaching cdroms (used to work in 3.x)
#              vm.medium_attachments.each do |m|
#                if m.type==:dvd
#                  #puts "Detaching dvd"
#                  m.detach
#                end
#              end
              
              vm.reload
              puts "We found no good state so we are destroying the previous machine+disks"
              destroy_vm(boxname)
            end
              
          end

          #puts "(re-)executing step #{step_name}"
          
         
          yield
 
          #Need to look it up again because if it was an initial load
          vm=VirtualBox::VM.find(boxname) 
          puts "Step [#{current_step_nr}] was succesfully - saving state"
          vm.save_state
          sleep 2 #waiting for it to be ok
          #puts "about to snapshot #{vm}"
          #take snapshot after succesful execution
          vm.take_snapshot(step_name,"snapshot taken by veewee")
          sleep 2 #waiting for it to be started again
          vm.start
        end   

        #pp snapnames
      end
      

  end #End Class
end #End Module
