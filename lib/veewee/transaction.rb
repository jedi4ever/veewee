module Veewee
  class Transaction

  def transaction(name,params, &block)
  end
  
  def transaction2(name,options= { :checksum => "nochecksum"}, &block)
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

  def self.remove_snapshot_vmachine(vmname,snapname)
    Shellutil.execute("VBoxManage snapshot '#{vmname}' delete '#{snapname}'")
  end

  def self.create_snapshot_vmachine(vmname,snapname)
    Shellutil.execute("VBoxManage snapshot '#{vmname}' take '#{snapname}'")
  end

  def self.load_snapshot_vmachine(vmname,snapname)
    #if it running , shutdown first
    if (state_vmachine(vmname)=="running")
      stop_vmachine(vmname)
    end

    Shellutil.execute("VBoxManage snapshot '#{vmname}' restore '#{snapname}'")
    #sometimes it takes some time to shutdown
    sleep 2
    Shellutil.execute("VBoxManage startvm '#{vmname}'")
  end

  def self.snapshot_exists(vmname,snapname)
    list_snapshots(vmname).each { |name|
      if (name==snapname) then
        return true
      end
    }
    return false
  end

  def self.snapshot_version_exists(vmname,snapname)
        list_snapshots(vmname).each { |name|
          if name.match(/^#{snapname}-/) then
            return true
          end
        }
        return false
  end

  def self.rollback_snapshot(vmname,snapname)
    delete_flag=false

    savestate_recover=false
    if (state_vmachine(vmname)=="running")
      Shellutil.execute("VBoxManage controlvm '#{vmname}' savestate")
      savestate_recover=true
     end

    list_snapshots(vmname).each { |name|
      if name.match(/^#{snapname}-/) then
        delete_flag=true
      end
      if (delete_flag) then
        remove_snapshot_vmachine(vmname,name)
      end
    }
    
    
     sleep 2

      Shellutil.execute("VBoxManage startvm '#{vmname}'")

      if (savestate_recover)
        #Recovering from savestate nukes the network! This trick seem to work
        #Also within the vm /etc/init.d/networking restart , but that is OS specific
        #http://www.virtualbox.org/ticket/5666
        #http://www.virtualbox.org/ticket/5654
        #This is supposed to be fixed: http://www.virtualbox.org/changeset/25205 but alas
        Shellutil.execute("VBoxManage controlvm '#{vmname}' nic1 nat")
        Shellutil.execute("VBoxManage controlvm '#{vmname}' setlinkstate1 off")
        Shellutil.execute("VBoxManage controlvm '#{vmname}' setlinkstate1 on")
        sleep 2

        #hmmm, virtualbox => when recovering from a restore , it looses the nat settings!!! So we need to do this again!!
        #thebox.ssh_enable_vmachine({:hostport => host_port , :guestport => 22} )
        #http://www.virtualbox.org/changeset/25402
        #[25402]: NAT: re-establish port-forwarding after savestate / restore state

      end

    end


    def self.list_snapshots(vmname)
      snapshotresult=Shellutil.execute("VBoxManage showvminfo --machinereadable '#{vmname}' |grep ^SnapshotName| cut -d '=' -f 2").stdout
      snapshotlist=snapshotresult.gsub(/\"/,'').split(/\n/)
      return snapshotlist
    end

end
end

    
