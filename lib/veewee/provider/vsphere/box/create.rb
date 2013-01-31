module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # When we create a new box
        # We assume the box is not running
        def create(options)

          network = retrieve_network options
          datastore = retrieve_datastore options
          host = retrieve_host options

          load_iso datastore, host
          create_vm datastore, network, host
          create_disk
          enable_vnc
        end

        def dc
          name ||= definition.vsphere[:vm_options][:datacenter]
          # if there's only one datacenter, use it (also works in standalone ESXi cases)
          if vim.serviceContent.rootFolder.children.grep(RbVmomi::VIM::Datacenter) == 1
            name ||= vim.serviceInstance.find_datacenter.name
          end
          @dc ||= vim.serviceInstance.find_datacenter name
          raise Veewee::Error, "Must specify a datacenter in the :vm_options section of your definition.rb" if @dc.nil?
          return @dc
        end

        def load_iso datastore, host_name
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

        def retrieve_datastore options
          # TODO Figure out whether there should be a default
          name ||= options["datastore"]
          name ||= definition.vsphere[:vm_options][:datastore]
          name ||= dc.datastore.first.name

          datastore = dc.find_datastore name

          raise Veewee::Error, "Datastore #{name} does not exist" if datastore.nil?
          env.ui.info "Using datastore #{name}"

          return datastore
        end

        def retrieve_host options
          name ||= definition.vsphere[:vm_options][:host]
          if dc.hostFolder.children.count == 1
            # this is a standalone ESXi
            name ||= dc.hostFolder.children[0].host[0].name
          end
          raise Veewee::Error, "Must specify a host in the :vm_options section of your definition.rb" if name.nil?

          host = vim.searchIndex.FindByDnsName(:dnsName => name, :vmSearch => false)

          raise Veewee::Error, "Network #{name} does not exist" if host.nil?
          env.ui.info "Using host #{name}"

          return host
        end

        def retrieve_network options
          # TODO Figure out whether there should be a default
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

        def create_vm datastore, network, host
          # TODO add cluster options so specifying a host can be optional
          pool = host.parent.resourcePool
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
