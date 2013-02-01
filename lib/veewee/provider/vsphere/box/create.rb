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

        # Retrieve datastore to install to
        #
        # Logic should look for the network in the following order:
        #   If datastore is specified as command line option and it exists, use that datastore
        #   If datastore is specified as vm option in definition and it exists, use that datastore
        #   If only one datastore exists and no datastore is specified, use that datastore
        # TODO All other use cases should result in an error being thrown
        #
        def retrieve_datastore options
          name ||= options["datastore"]
          name ||= definition.vsphere[:vm_options][:datastore]
          name ||= dc.datastore.first.name

          datastore = dc.find_datastore name

          raise Veewee::Error, "Datastore #{name} does not exist" if datastore.nil?
          env.ui.info "Using datastore #{name}"

          return datastore
        end

        # Retrieve the specified network to attach the VM to
        #
        # Logic should look for the network in the following order:
        #   If network is specified as command line option and it exists, use that network
        #   If network is specified as vm option in definition and it exists, use that network
        #   If only one network exists and no network is specified, use that network
        # TODO All other use cases should result in an error being thrown
        #
        def retrieve_network options
          name ||= options["network"]
          name ||= definition.vsphere[:vm_options][:network]
          name ||= dc.network.first.name
          network = dc.network.find { |x| x.name == name }

          raise Veewee::Error, "Network #{name} does not exist" if network.nil?
          env.ui.info "Using network #{name}"

          return network
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
