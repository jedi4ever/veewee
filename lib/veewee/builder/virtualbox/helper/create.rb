module Veewee
  module Builder
    module Virtualbox
      module BoxHelper
        
def add_ide_controller(definition)
  #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
  command ="#{@vboxcmd} storagectl '#{name}' --name 'IDE Controller' --add ide"
  Veewee::Util::Shell.execute("#{command}")
end

def add_sata_controller(definition)
  #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
  command ="#{@vboxcmd} storagectl '#{name}' --name 'SATA Controller' --add sata --hostiocache #{definition.hostiocache} --sataportcount 1"
  Veewee::Util::Shell.execute("#{command}")
end

def add_ssh_nat_mapping(definition)
 
  #Map SSH Ports
  #			command => "${vboxcmd} modifyvm '${vname}' --natpf1 'guestssh,tcp,,${hostsshport},,${guestsshport}'",
  port = VirtualBox::NATForwardedPort.new
  port.name = "guestssh"
  port.guestport = definition.ssh_guest_port.to_i
  port.hostport = definition.ssh_host_port.to_i
  raw.network_adapters[0].nat_driver.forwarded_ports << port
  port.save
  raw.save
end

def raw
  vm=VirtualBox::VM.find(name)
  return vm
end

def add_shared_folder(definition)

#  command="#{@vboxcmd} sharedfolder add  '#{name}' --name 'veewee-validation' --hostpath '#{File.expand_path(@environment.validation_dir)}' --automount"
#  Veewee::Util::Shell.execute("#{command}")

end

def get_vm_location
  command="#{@vboxcmd}  list  systemproperties"
  shell_results=Veewee::Util::Shell.execute("#{command}",{:mute => true})
  location=shell_results.stdout.split(/\n/).grep(/Default machine/)[0].split(":")[1].strip
  return location
end

def verify_ostype(definition)

  #Verifying the os.id with the :os_type_id specified
  matchfound=false
  VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
    if definition.os_type_id == os.id
      matchfound=true
    end
  }
  unless matchfound
    env.ui.error "The ostype: #{definition.os_type_id} is not available in your Virtualbox version"
    exit -1
  end

end

def suppress_messages
  #Setting this annoying messages to register
  VirtualBox::ExtraData.global["GUI/RegistrationData"]="triesLeft=0"
  VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, 2009-09-20"
  VirtualBox::ExtraData.global["GUI/SuppressMessages"]="confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff"
  VirtualBox::ExtraData.global["GUI/UpdateCheckCount"]="60"
  update_date=Time.now+86400
  VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, #{update_date.year}-#{update_date.month}-#{update_date.day}, stable"
  VirtualBox::ExtraData.global.save
end


  def create_floppy(definition)
    # Todo Check for java
    # Todo check output of commands

    # Check for floppy
    unless definition.floppy_files.nil?
      require 'tmpdir'
      temp_dir=Dir.tmpdir
      definition.floppy_files.each do |filename|
        full_filename=full_filename=File.join(definition.path,filename)
        FileUtils.cp("#{full_filename}","#{temp_dir}")
      end
      javacode_dir=File.expand_path(File.join(__FILE__,'..','..','java'))
      floppy_file=File.join(definition.path,"virtualfloppy.vfd")
      command="java -jar #{javacode_dir}/dir2floppy.jar '#{temp_dir}' '#{floppy_file}'"
      Veewee::Util::Shell.execute("#{command}")
    end
  end
        
        def create_disk(definition)
          # Now check the disks
          # Maybe one day we can use the name, now we have to check location
          # disk=VirtualBox::HardDrive.find(box_name)
          location=name+"."+definition.disk_format.downcase
          found=false
          VirtualBox::HardDrive.all.each do |d|
            if !d.location.match(/#{location}/).nil?
              found=true
              break
            end
          end

          # Sometimes the above doesn't find a registered harddisk, but the vdi files is still there
          if File.exists?(location)
            puts "#{location} file still exists but isn't registered"
            puts "Let me clean up that mess for you."
            FileUtils.rm(location)
          end

          if !found
            puts "Creating new harddrive of size #{definition.disk_size.to_i} "

            #newdisk=VirtualBox::HardDrive.new
            #newdisk.format=definition[:disk_format]
            #newdisk.logical_size=definition[:disk_size].to_i

            #newdisk.location=location
            ##PDB: again problems with the virtualbox GEM
            ##VirtualBox::Global.global.max_vdi_size=1000000
            #newdisk.save

            place=get_vm_location
            command ="#{@vboxcmd} createhd --filename '#{place}/#{name}/#{name}.#{definition.disk_format.downcase}' --size '#{definition.disk_size.to_i}' --format #{definition.disk_format.downcase}"
            Veewee::Util::Shell.execute("#{command}")
          end

        end

        def attach_disk(definition)

          place=get_vm_location
          location=name+"."+definition.disk_format.downcase

          location="#{place}/#{name}/"+location
          puts "Attaching disk: #{location}"

          #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
          command ="#{@vboxcmd} storageattach '#{name}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
          Veewee::Util::Shell.execute("#{command}")

        end
        
        
        def attach_isofile(definition)
          full_iso_file=File.join(env.config.veewee.iso_dir,definition.iso_file)
          puts "Mounting cdrom: #{full_iso_file}"
          #command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
          command ="#{@vboxcmd} storageattach '#{name}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}'"
          Veewee::Util::Shell.execute("#{command}")
        end
        
  
  def add_floppy_controller(definition)
    # Create floppy controller
    unless definition.floppy_files.nil?
    
      command="#{@vboxcmd} storagectl '#{name}' --name 'Floppy Controller' --add floppy"
      Veewee::Util::Shell.execute("#{command}")
    end
  end
  
  
  def attach_floppy(definition)
    unless definition.floppy_files.nil?
    
    # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
    floppy_file=File.join(definition.path,"virtualfloppy.vfd")        
    command="#{@vboxcmd} storageattach '#{name}' --storagectl 'Floppy Controller' --port 0 --device 0 --type fdd --medium '#{floppy_file}'"
    Veewee::Util::Shell.execute("#{command}")
    end
  end

  def create_vm(definition)
     command="#{@vboxcmd} createvm --name '#{name}' --ostype '#{definition.os_type_id}' --register"

      #Exec and system stop the execution here
      Veewee::Util::Shell.execute("#{command}")

      env.ui.info "Creating vm #{name} : #{definition.memory_size}M - #{definition.cpu_count} CPU - #{definition.os_type_id}"

      #setting cpu's    
      command="#{@vboxcmd} modifyvm '#{name}' --cpus #{definition.cpu_count}"
      Veewee::Util::Shell.execute("#{command}")

      #setting memory size    
      command="#{@vboxcmd} modifyvm '#{name}' --memory #{definition.memory_size}"
      Veewee::Util::Shell.execute("#{command}")

      #setting bootorder    
      command="#{@vboxcmd} modifyvm '#{name}' --boot1 disk --boot2 dvd --boot3 none --boot4 none"
      Veewee::Util::Shell.execute("#{command}")

      # Modify the vm to enable or disable hw virtualization extensions
      vm_flags=%w{pagefusion acpi ioapic pae hpet hwvirtex hwvirtexcl nestedpaging largepages vtxvpid synthxcpu rtcuseutc}

      vm_flags.each do |vm_flag|
        if definition.instance_variable_defined?("@#{vm_flag}")
          vm_flag_value=definition.instance_variable_get("@#{vm_flag}")
          env.ui.info "Setting VM Flag #{vm_flag} to #{vm_flag_value}"
          command="#{@vboxcmd} modifyvm #{name} --#{vm_flag.to_s} #{vm_flag_value}"
          Veewee::Util::Shell.execute("#{command}")
        end
      end
        

    raw.reload
        
  end
end
end
end
end
