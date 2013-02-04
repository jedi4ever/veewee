module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # When we create a new box
        # We assume the box is not running
        def create(options)
          network = retrieve_network options
          datastore = retrieve_datastore options
          compute_resource = retrieve_compute_resource

          # Verify network and datastore are not only accessible from the datacenter
          # but also from the specific compute resource (host or cluster) being used
          if compute_resource.network.find { |x| x.name == network.name }.nil?
            raise Veewee::Error, "Network #{network.name} is not accessible from compute resource #{compute_resource.name}"
          elsif compute_resource.datastore.find { |x| x.name == datastore.name }.nil?
            raise Veewee::Error, "Datastore #{datastore.name} is not accessible from compute resource #{compute_resource.name}"
          end

          load_iso datastore
          create_vm datastore, network, compute_resource
          create_disk
          enable_vnc
        end

        # Load ISO to vSphere datastore, assumes same datastore as VM will be built on
        def load_iso datastore
          filename = definition.iso_file
          local_path=File.join(env.config.veewee.iso_dir,filename)
          File.exists?(local_path) or fail "ISO does not exist"

          # These checks need to be done in this order
          # otherwise the requests to the datastore over
          # http will hang. (Observed in ESXi 4.1 update 3)
          unless datastore.exists? "isos/"
            vim.serviceContent.fileManager.MakeDirectory :name => "[#{datastore.name}] isos", :datacenter => dc
          end
          unless datastore.exists? "isos/"+filename
            env.ui.info "Loading ISO to vSphere Host"
            datastore.upload "isos/"+filename, local_path
          end
        end

        def create_disk
          env.ui.info "Creating virtual disk"
          add_disk "#{definition.disk_size}M"
        end

        def vsphere_os_type(type_id)
          env.logger.info "Translating #{type_id} into vsphere type"
          vspheretype=env.ostypes[type_id][:vsphere]
          env.logger.info "Found vsphere type #{vspheretype}"
          return vspheretype
        end

        def create_vm datastore, network, compute_resource
          # TODO verify that single host compute resources and clusters cannot create name collisions
          pool = compute_resource.resourcePool
          vmFolder = dc.vmFolder
          datastore_path = "[#{datastore.name}]"
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
                    :summary => network.name,
                    :label => "",
                  },
                  # TODO Verify this works with Distributed vSwitch configurations
                  :backing => VIM.VirtualEthernetCardNetworkBackingInfo(:deviceName => network.name),
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
