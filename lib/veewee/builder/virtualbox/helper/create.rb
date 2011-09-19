
def add_ide_controller
  #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
  command ="#{@vboxcmd} storagectl '#{@box_name}' --name 'IDE Controller' --add ide"
  Veewee::Util::Shell.execute("#{command}")
end

def add_sata_controller
  #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
  command ="#{@vboxcmd} storagectl '#{@box_name}' --name 'SATA Controller' --add sata --hostiocache #{@definition.hostiocache}"
  Veewee::Util::Shell.execute("#{command}")
end

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


  def create_floppy
    # Todo Check for java
    # Todo check output of commands

    # Check for floppy
    unless @definition.floppy_files.nil?
      require 'tmpdir'
      temp_dir=Dir.tmpdir
      @definition.floppy_files.each do |filename|
        full_filename=full_filename=File.join(@environment.definition_dir,@box_name,filename)
        FileUtils.cp("#{full_filename}","#{temp_dir}")
      end
      javacode_dir=File.expand_path(File.join(__FILE__,'..','..','java'))
      floppy_file=File.join(@environment.definition_dir,@box_name,"virtualfloppy.vfd")
      command="java -jar #{javacode_dir}/dir2floppy.jar '#{temp_dir}' '#{floppy_file}'"
      Veewee::Util::Shell.execute("#{command}")
    end
  end
        
        def create_disk
          # Now check the disks
          # Maybe one day we can use the name, now we have to check location
          # disk=VirtualBox::HardDrive.find(box_name)
          location=@box_name+"."+@definition.disk_format.downcase
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
            puts "Creating new harddrive of size #{@definition.disk_size.to_i} "

            #newdisk=VirtualBox::HardDrive.new
            #newdisk.format=@definition[:disk_format]
            #newdisk.logical_size=@definition[:disk_size].to_i

            #newdisk.location=location
            ##PDB: again problems with the virtualbox GEM
            ##VirtualBox::Global.global.max_vdi_size=1000000
            #newdisk.save

            place=get_vm_location
            command ="#{@vboxcmd} createhd --filename '#{place}/#{@box_name}/#{@box_name}.#{@definition.disk_format.downcase}' --size '#{@definition.disk_size.to_i}' --format #{@definition.disk_format.downcase}"
            Veewee::Util::Shell.execute("#{command}")
          end

        end

        def attach_disk

          place=get_vm_location
          location=@box_name+"."+@definition.disk_format.downcase

          location="#{place}/#{@box_name}/"+location
          puts "Attaching disk: #{location}"

          #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
          command ="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
          Veewee::Util::Shell.execute("#{command}")

        end
        
        
        def attach_isofile
          full_iso_file=File.join(@environment.iso_dir,@definition.iso_file)
          puts "Mounting cdrom: #{full_iso_file}"
          #command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
          command ="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}'"
          Veewee::Util::Shell.execute("#{command}")
        end
        
  
  def add_floppy_controller
    # Create floppy controller
    unless @definition.floppy_files.nil?
    
      command="#{@vboxcmd} storagectl '#{@box_name}' --name 'Floppy Controller' --add floppy"
      Veewee::Util::Shell.execute("#{command}")
    end
  end
  
  
  def attach_floppy
    unless @definition.floppy_files.nil?
    
    # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
    floppy_file=File.join(@environment.definition_dir,@box_name,"virtualfloppy.vfd")        
    command="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'Floppy Controller' --port 0 --device 0 --type fdd --medium '#{floppy_file}'"
    Veewee::Util::Shell.execute("#{command}")
    end
  end
end