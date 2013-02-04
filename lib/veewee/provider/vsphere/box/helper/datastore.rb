module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Retrieve datastore to install to
        #
        # Logic should look for the datastore in the following order:
        #   If datastore is specified as command line option and it exists, use that datastore
        #   If datastore is specified as vm option in definition and it exists, use that datastore
        #   If only one datastore exists and no datastore is specified, use that datastore
        # TODO All other use cases should result in an error being thrown
        #
        def retrieve_datastore options
          name ||= options["datastore"]
          name ||= definition.vsphere[:vm_options][:datastore]

          unless name.nil?
            datastore = dc.find_datastore name
            raise Veewee::Error, "Datastore #{name} was not found on the vSphere server in datacenter #{dc.name}\n" + valid_datastores if datastore.nil?
          else
            raise Veewee::Error, "Multiple datastores found in datacenter #{dc.name}, you must specify a name\n" + valid_datastores if dc.datastore.count > 1

            # There is only one datastore, choose that datastore
            datastore = dc.datastore.first
          end

          raise Veewee::Error, "Veewee could not find a datastore to use, consult your ESXi or vCenter server to see if it is working as expected" if datastore.nil?
          env.ui.info "Using datastore #{datastore.name}"

          return datastore
        end
        
        # Retrieve the valid datastores to inform the users what selections they can make
        def valid_datastores
          rval = "The following datastores are available for datacenter #{dc.name}:\n"
          dc.datastore.each do | datastore |  
            rval += "   " + datastore.name + "\n"
          end
          rval += "Modify :vsphere=>{:vm_options=>{:datastore=>'<VALUE>'}} in your definition.rb to specify a compute resource"

          return rval
        end

      end
    end
  end
end
