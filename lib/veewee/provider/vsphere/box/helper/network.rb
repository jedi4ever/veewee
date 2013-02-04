module Veewee
  module Provider
    module Vsphere
      module BoxCommand

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

          unless name.nil?
            network = dc.network.find { |x| x.name == name }
            raise Veewee::Error, "Network #{name} was not found on the vSphere server in datacenter #{dc.name}\n" + valid_networks if network.nil?
          else
            raise Veewee::Error, "Multiple networks found in datacenter #{dc.name}, you must specify a name\n" + valid_networks if dc.network.count > 1

            # There is only one datastore, choose that network
            network = dc.network.first
          end

          raise Veewee::Error, "Veewee could not find a network to use, consult your ESXi or vCenter server to see if it is working as expected" if network.nil?
          env.ui.info "Using network #{network.name}"

          return network
        end

        # Retrieve the valid networks to inform the users what selections they can make
        def valid_networks
          rval = "The following networks are available for datacenter #{dc.name}:\n"
          dc.network.each do | network |  
            rval += "   " + network.name + "\n"
          end
          rval += "Modify :vsphere=>{:vm_options=>{:network=>'<VALUE>'}} in your definition.rb to specify a compute resource"

          return rval
        end

      end
    end
  end
end
