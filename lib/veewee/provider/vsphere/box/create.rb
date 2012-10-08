module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # When we create a new box
        # We assume the box is not running
        def create(options)
          datastore_name = retrieve_datastore options["datastore"]

          load_iso datastore_name
          create_vm datastore_name
          create_disk
          enable_vnc
        end

        def load_iso datastore_name
          env.ui.info "Loading ISO to Host"
          filename = definition.iso_file
          local_path=File.join(env.config.veewee.iso_dir,filename)
          File.exists?(local_path) or fail "ISO does not exist"
          dc = vim.serviceInstance.find_datacenter
          datastore = dc.find_datastore datastore_name
          unless datastore.exists? "isos/"+filename
            unless datastore.exists? "isos/"
              vim.serviceContent.fileManager.MakeDirectory :name => "[#{datastore_name}] isos", :datacenter => dc
            end
            datastore.upload "isos/"+filename, local_path
          end
        end

        def retrieve_datastore name
          dc = vim.serviceInstance.find_datacenter
          name = dc.datastoreFolder.childEntity[0].name if name.nil? 
          datastore = dc.find_datastore name

          raise Veewee::Error, "Datastore #{name} does not exist" if datastore.nil? 

          return name 
        end

        def create_disk
          env.ui.info "Creating disk"
          add_disk "#{definition.disk_size}M"
        end

        def vsphere_os_type(type_id)
          env.logger.info "Translating #{type_id} into vsphere type"
          vspheretype=env.ostypes[type_id][:vsphere]
          env.logger.info "Found vsphere type #{vspheretype}"
          return vspheretype
        end

        def create_vm datastore_name
          dc = vim.serviceInstance.find_datacenter
          pool = dc.hostFolder.childEntity[0].resourcePool
          vmFolder = dc.vmFolder
          datastore_name= dc.datastoreFolder.childEntity[0].name if datastore_name.nil? 
          datastore_path = "[#{datastore_name}]"
          config = {
            :name => definition.name,
            :guestId => vsphere_os_type(definition.os_type_id),
            :files => { :vmPathName => datastore_path }, 
            :numCPUs => definition.cpu_count,
            :memoryMB => definition.memory_size,
            :deviceChange => [
              {
                :operation => :add,
                :device => VIM.VirtualCdrom(
                  :key => -2,
                  :connectable => {
                    :allowGuestControl => true,
                    :connected => true,
                    :startConnected => true,
                  },
                  :backing => VIM.VirtualCdromIsoBackingInfo(
                    :fileName => datastore_path + " isos/" + definition.iso_file
                  ),
                  :controllerKey => 200,
                  :unitNumber => 0
                )
              },
              {
                :operation => :add,
                :device => VIM.VirtualLsiLogicController(
                  :key => -1,
                  :busNumber => 0,
                  :sharedBus => 'noSharing',
                  :hotAddRemove => nil
                )
              },
              {
                :operation => :add,
                :device => VIM.VirtualE1000(
                  :key => -1,
                  :deviceInfo => {
                    :summary => definition.vsphere[:vm_options][:network],
                    :label => "",
                  },
                  :backing => VIM.VirtualEthernetCardNetworkBackingInfo(:deviceName => definition.vsphere[:vm_options][:network]),
                  :addressType => 'generated'
                )
              }
            ],
          } 

          vmFolder.CreateVM_Task(:config=>config,
                                 :pool=>pool).wait_for_completion

        end
      end
    end
  end
end
