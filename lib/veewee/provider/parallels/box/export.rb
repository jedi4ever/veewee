require 'pathname'
require 'erb'
module Veewee
  module Provider
    module Parallels
      module BoxCommand

        class ErbBinding < OpenStruct
          def get_binding
            return binding()
          end
        end

        def export_vagrant(options)
          # For now, we just assume prlctl is in the path. If not...it'll fail.
          @prlcmd = "prlctl"

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

          #Vagrant requires a relative path for output of boxes

          #4.0.x. not using boxes as a subdir
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

          begin

            ui.info "Adding additional files"

            # Handling the Vagrantfile
            if options["vagrantfile"].to_s == ""

              # Fetching mac address

              data = {
                :macaddress => get_mac_address
              }

              # Prepare the vagrant erb
              vars = ErbBinding.new(data)
              template_path = File.join(File.dirname(__FILE__),'..','..','..','templates',"Vagrantfile.erb")
              template = File.open(template_path).readlines.join
              erb = ERB.new(template)
              vars_binding = vars.send(:get_binding)
              result = erb.result(vars_binding)
              ui.info("Creating Vagrantfile")
              vagrant_path = File.join(tmp_dir,'Vagrantfile')
              env.logger.debug("Path: #{vagrant_path}")
              env.logger.debug(result)
              File.open(vagrant_path,'w') {|f| f.write(result) }
            else
              f = options["vagrantfile"]
              env.logger.debug("Including vagrantfile: #{f}")
              FileUtils.cp(f,File.join(tmp_dir,"Vagrantfile"))
            end

            #Inject a metadata.json file
            ui.info("Adding metadata.json file for Parallels Desktop provider")
            File.open(File.join(tmp_dir, 'metadata.json'), 'w') {|f| f.write(template_metadatafile()) }

            ui.info "Exporting the box"
            # TODO: Copy directory from path to the tmp dir
            vm_path = get_vm_path
            tmp_dest = File.join(tmp_dir, "box.pvm")
            FileUtils.cp_r(vm_path, tmp_dest)
            env.logger.debug("Copy #{vm_path} to #{tmp_dest}")

            ui.info "Packaging the box"
            FileUtils.cd(tmp_dir)
            command_box_path = box_path
            # Gzip, for extra smallness
            command = "tar -cvzf '#{command_box_path}' ."
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
          ui.info "vagrant up --provider=parallels"
          ui.info "vagrant ssh"
        end

        def get_mac_address
          command = "#{@prlcmd} list --info --json \"#{self.name}\""
          shell_results = shell_exec("#{command}")
          # Parsing trick borrowed from vagrant-parallels, lib/vagrant-parallels/driver/
          json = JSON.parse(shell_results.stdout.gsub("/\s+/", "").gsub(/^(INFO)?\[/, '').gsub(/\]$/, ''))
          # TODO: Not sure if all Parallels guests use net0, but it seems good enough for now.
          mac = json.fetch("Hardware").fetch("net0").fetch("mac")
          env.logger.debug("mac address: #{mac}")
          return mac
        end

        def get_vm_path
          # TODO: Remove this duplication. Maybe make a function higher up somewhere.
          command = "#{@prlcmd} list --info --json \"#{self.name}\""
          shell_results = shell_exec("#{command}")
          # Parsing trick borrowed from vagrant-parallels, lib/vagrant-parallels/driver/
          json = JSON.parse(shell_results.stdout.gsub("/\s+/", "").gsub(/^(INFO)?\[/, '').gsub(/\]$/, ''))
          # TODO: Do we need to catch errors here? I mean if they got this far it should exist...
          vm_path = File.realpath(json.fetch("Home"))
          env.logger.debug("path to VM: #{vm_path}")
          return vm_path
        end

        def template_metadatafile
          %Q({"provider": "parallels"}\n)
        end

      end #Module
    end #Module
  end #Module
end #Module
