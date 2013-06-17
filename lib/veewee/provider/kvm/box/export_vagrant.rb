require 'pathname'
require 'erb'
module Veewee
  module Provider
    module Kvm
      module BoxCommand
        def export_vagrant(options)

          # Check if box already exists
          unless self.exists?
            ui.info "#{name} is not found, maybe you need to build it first?"
            exit
          end

          if File.exists?("#{name}.box")
            if options["force"]
              env.logger.debug("#{name}.box exists, but --force was provided")
              env.logger.debug("removing #{name}.box first")
              FileUtils.rm("#{name}.box")
              env.logger.debug("#{name}.box removed")
            else
              raise Veewee::Error, "export file #{name}.box already exists. Use --force option to overwrite."
            end
          end

          # We need to shutdown first
          if self.running?
            ui.info "Vagrant requires the box to be shutdown, before it can export"
            ui.info "Sudo also needs to work for user #{definition.ssh_user}"
            ui.info "Performing a clean shutdown now."

            self.halt

            #Wait for state poweroff
            while (self.running?) do
              ui.info ".",{:new_line => false}
              sleep 1
            end
            ui.info ""
            ui.info "Machine #{name} is powered off cleanly"
          end

          # Vagrant requires a relative path for output of boxes
          boxdir=Pathname.new(Dir.pwd)
          full_path=File.join(boxdir,name+".box")
          path1=Pathname.new(full_path)
          path2=Pathname.new(Dir.pwd)
          box_path=File.expand_path(path1.relative_path_from(path2).to_s)

          if File.exists?("#{box_path}")
            raise Veewee::Error, "box #{name}.box already exists"
          end

          # Create temp directory
          current_dir = FileUtils.pwd
          ui.info "Creating a temporary directory for export"
          tmp_dir = Dir.mktmpdir
          env.logger.debug("Create temporary directory for export #{tmp_dir}")

          server = @connection.servers.all(:name => name).first
          volume = server.volumes.find(&:path)

          begin
            ui.info "Adding additional files"

            # Handling the Vagrantfile
            if options["vagrantfile"].to_s == ""
              # Prepare the vagrant erb
              template_path = File.join(File.dirname(__FILE__),'..','templates',"Vagrantfile")
              ui.info("Creating Vagrantfile")
              FileUtils.cp(template_path, File.join(tmp_dir,'Vagrantfile'))
            else
              f = options["vagrantfile"]
              env.logger.debug("Including vagrantfile: #{f}")
              FileUtils.cp(f,File.join(tmp_dir,"Vagrantfile"))
            end

            # Inject a metadata.json file
            File.open(File.join(tmp_dir, 'metadata.json'), 'w') {|f| f.write(template_metadatafile(volume.capacity)) }

            # Handling other includes
            unless options["include"].nil?
              options["include"].each do |f|
                env.logger.debug("Including file: #{f}")
                FileUtils.cp(f,File.join(tmp_dir,f))
              end
            end

            # Final image must be qcow2 for vagrant-libvirt
            # This also allows us to make the image sparse again after zerodisk.sh has run
            # both qemu-img and virt-sparsify can do this, but the latter is better
            volume_out = File.join(tmp_dir, 'box.img')
            if options['sparsify']
              ui.info "Sparsifying and copying the box volume"
              command = "virt-sparsify --machine-readable #{volume.path} --convert qcow2 #{volume_out}"
            else
              ui.info "Copying the box volume"
              command = "qemu-img convert -O qcow2 #{volume.path} #{volume_out}"
            end
            env.logger.debug("Source volume: #{volume.path}")
            env.logger.debug(command)
            shell_exec command

            ui.info "Packaging the box"
            FileUtils.cd(tmp_dir)
            command = "tar -cvf '#{box_path}' ."
            env.logger.debug(command)
            shell_exec (command)

          rescue Errno::ENOENT => ex
            raise Veewee::Error, "#{ex}"
          rescue Error => ex
            raise Veewee::Error, "Packaging of the box failed:\n+#{ex}"
          ensure
            # Remove temporary directory
            ui.info "Cleaning up temporary directory"
            env.logger.debug("Removing temporary dir #{tmp_dir}")
            FileUtils.rm_rf(tmp_dir)

            FileUtils.cd(current_dir)
          end
          ui.info ""
          ui.info "To import it into vagrant type:"
          ui.info "vagrant box add '#{name}' '#{box_path}'"
          ui.info ""
          ui.info "To use it:"
          ui.info "vagrant init '#{name}'"
          ui.info "vagrant up --provider=libvirt"
          ui.info "vagrant ssh"
        end

        def template_metadatafile size
          {
            "provider"     => "libvirt",
            "format"       => "qcow2",
            "virtual_size" => size+1  # fog rounds down
          }.to_json
        end

      end #Module
    end #Module
  end #Module
end #Module
