require 'pathname'
require 'erb'
module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        class ErbBinding < OpenStruct
          def get_binding
            return binding()
          end
        end

        #    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})

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

            # Handling other includes
            unless options["include"].nil?
              options["include"].each do |f|
                env.logger.debug("Including file: #{f}")
                FileUtils.cp(f,File.join(tmp_dir,f))
              end
            end

            ui.info "Exporting the box"
            command = "#{@vboxcmd} export \"#{name}\" --output \"#{File.join(tmp_dir,'box.ovf')}\""
            env.logger.debug("Command: #{command}")
            shell_exec(command, {:mute => false})

            ui.info "Packaging the box"
            FileUtils.cd(tmp_dir)
            command_box_path = box_path
            is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
            if is_windows
              command_box_path = command_box_path.gsub(/^([A-Z])\:\/(.*)$/i, '/\1/\2')
            end
            command = "tar -cvf '#{command_box_path}' ."
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

          #add_ssh_nat_mapping back!!!!
          #vagrant removes the mapping
          #we need to restore it in order to be able to login again
          #self.add_ssh_nat_mapping

          ui.info "To import it into vagrant type:"
          ui.info "vagrant box add '#{name}' '#{box_path}'"
          ui.info ""
          ui.info "To use it:"
          ui.info "vagrant init '#{name}'"
          ui.info "vagrant up"
          ui.info "vagrant ssh"
        end

        def get_mac_address
          command = "#{@vboxcmd} showvminfo --details --machinereadable \"#{self.name}\""
          shell_results = shell_exec("#{command}")
          mac = shell_results.stdout.split(/\n/).grep(/^macaddress1/)[0].split('=')[1].split('"')[1]
          env.logger.debug("mac address: #{mac}")
          return mac
        end

      end #Module
    end #Module
  end #Module
end #Module


#      #currently vagrant has a problem with the machine up, it calculates the wrong port to ssh to poweroff the system
#      thebox.execute("shutdown -h now")
#      thebox.wait_for_state("poweroff")


#      Shellutil.execute("echo 'Vagrant::Config.run do |config|' > /tmp/Vagrantfile")
#      Shellutil.execute("echo '   config.ssh.forwarded_port_key = \"ssh\"' >> /tmp/Vagrantfile")
#      Shellutil.execute("echo '   config.raw.forward_port(\"ssh\",22,#{host_port})' >> /tmp/Vagrantfile")
#      Shellutil.execute("echo 'end' >> /tmp/Vagrantfile")


#vagrant export disables the machine
#      thebox.ssh_enable_vmachine({:hostport => host_port , :guestport => 22} )
