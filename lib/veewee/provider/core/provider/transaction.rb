##Note: this is currently not used anymore, it seems no one is using it

module Veewee
  class Transaction

  def transaction(name,params, &block)
  end

  def transaction2(name,options= { :checksum => "nochecksum"}, &block)
     if snapshot_exists(@vmname,name+"-"+options[:checksum])
        load_snapshot_vmachine(@vmname,name+"-"+options[:checksum])
      else
        if snapshot_version_exists(@vmname,name)
          rollback_snapshot(@vmname,name)
          #rollback to snapshot prior to this one
        end
        yield
        create_snapshot_vmachine(@vmname,name+"-"+options[:checksum])
      end
    #end
  end


end
end
