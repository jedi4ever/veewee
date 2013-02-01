module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Retrieve datacenter to use
        #
        # Logic should look for the datacenter in the following order:
        #   If datacenter is specified as vm option in definition and it exists, use that datacenter
        #   If only one datacenter exists and no datacenter is specified, use that datacenter
        # All other conditions result in errors
        def retrieve_datacenter
          # Retrieve the name from the vm_options, if available
          name ||= definition.vsphere[:vm_options][:datacenter]

          unless name.nil?
            # If provided a name, attempt to retrieve datacenter, if its not found raise an error
            @dc ||= vim.serviceInstance.find_datacenter name
            raise Veewee::Error, "Datacenter #{name} was not found on the vSphere server\n" + valid_datacenters if @dc.nil?
          else
            # If multiple datacenters are found, but no name is provided, raise an error
            raise Veewee::Error, "Multiple datacenters found, you must specify a name\n" + valid_datacenter if vim.serviceContent.rootFolder.children.grep(RbVmomi::VIM::Datacenter).count > 1

            # if there's only one datacenter, use it (also works in standalone ESXi cases)
            # Call find datacenter to retrieve the single datacenter found
            @dc ||= vim.serviceInstance.find_datacenter
          end
          
          raise Veewee::Error, "Veewee could not find a datacenter to use, consult your ESXi or vCenter server to see if it is working as expected" if @dc.nil?
          
          return @dc
        end

        # Retrieve the valid datacenters to inform the users what selections they can make
        def valid_datacenters
          rval = "The following datacenters are available:\n"
          vim.serviceContent.rootFolder.children.grep(RbVmomi::VIM::Datacenter).each do | datacenter |
            rval += "   " + datacenter.name + "\n"
          end
          rval += "Modify :vsphere=>{:vm_options=>{:datacenter=>'<VALUE>'}} in your definition.rb to specify a datacenter"

          return rval
        end

      end
    end
  end
end
