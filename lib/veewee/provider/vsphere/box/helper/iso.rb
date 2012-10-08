module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def load_iso datastore_name
          env.ui.info "Loading ISO to Host"
          filename = definition.iso_file
          local_path=File.join(env.config.veewee.iso_dir,filename)
          File.exists?(local_path) or fail "ISO does not exist"
          dc = vim.serviceInstance.find_datacenter
          datastore = dc.find_datastore datastore_name
          unless datastore.exists? "isos/"+filename
            unless datstore.exists? "isos/"
              vim.serviceContent.fileManager.MakeDirectory :name => "[#{datastore_name}] isos", :datacenter => dc
            end
            datastore.upload "isos/"+filename, local_path
          end
        end

      end
    end
  end
end
