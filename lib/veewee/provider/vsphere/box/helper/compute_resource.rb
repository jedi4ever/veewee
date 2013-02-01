module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Retrieve the Compute Resource to install to
        #
        # In the case of vSphere ESXi, there is one compute resource
        # that encapsulates the ESXi server
        #
        # In the case of vCenter, there are one or more compute resources
        # that represent a single ESXi server or a cluster
        #
        # If multiple Compute Resources exist and a name is not provided,
        #   an error is raise
        #
        def retrieve_compute_resource
          # Retrieve the name from the vm_options, if available
          name ||= definition.vsphere[:vm_options][:compute_resource]

          unless name.nil?
            # Retrieve compute resource by name
            compute_resource = dc.find_compute_resource name
            raise Veewee::Error, "Compute Resource #{name} was not found on the vSphere server\n" + valid_compute_resources if compute_resource.nil?
          else
            # If no name was provided, and there are multiple resources, raise an error
            raise Veewee::Error, "Multiple compute resources found, you must specify a name\n" + valid_compute_resources if dc.hostFolder.children.count > 1
            
            # this is a standalone ESXi or single compute resource vCenter
            name ||= dc.hostFolder.children[0].name
            compute_resource = dc.find_compute_resource name
          end

          raise Veewee::Error, "Veewee could not find a compute resource to use, consult your ESXi or vCenter server to see if it is working as expected" if compute_resource.nil?

          env.ui.info "Using Compute Resource #{name}"

          return compute_resource
        end

        # Retrieve the valid compute resources to inform the users what selections they can make
        def valid_compute_resources
          rval = "The following compute resources (i.e., hosts or clusters) are available:\n"
          dc.hostFolder.children.each do | compute_resource |  
            rval += "   " + compute_resource.name + "\n"
          end
          rval += "Modify :vsphere=>{:vm_options=>{:compute_resource=>'<VALUE>'}} in your definition.rb to specify a compute resource"

          return rval
        end

      end
    end
  end
end
