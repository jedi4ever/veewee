require 'pathname'
module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        #    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})

        def export_vagrant(options)

          # Check if box already exists
          unless self.exists?
            env.ui.info "#{name} is not found, maybe you need to build it first?"
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
            env.ui.info "Vagrant requires the box to be shutdown, before it can export"
            env.ui.info "Sudo also needs to work for user #{definition.ssh_user}"
            env.ui.info "Performing a clean shutdown now."

            self.shutdown

            #Wait for state poweroff
            while (self.running?) do
              env.ui.info ".",{:new_line => false}
              sleep 1
            end
            env.ui.info ""
            env.ui.info "Machine #{name} is powered off cleanly"
          end

          #Vagrant requires a relative path for output of boxes

          #4.0.x. not using boxes as a subdir
          boxdir=Pathname.new(Dir.pwd)

          full_path=File.join(boxdir,name+".box")
          path1=Pathname.new(full_path)
          path2=Pathname.new(Dir.pwd)
          box_path=path1.relative_path_from(path2).to_s

          if File.exists?("#{box_path}")
            env.ui.info "box #{name}.box already exists"
            exit
          end

          env.ui.info "Excuting vagrant voodoo:"
          export_command="vagrant package --base '#{name}' --output '#{box_path}'"
          env.ui.info "#{export_command}"
          shell_exec("#{export_command}") #hmm, needs to get the gem_home set?
          env.ui.info ""

          #add_ssh_nat_mapping back!!!!
          #vagrant removes the mapping
          #we need to restore it in order to be able to login again
          self.add_ssh_nat_mapping

          env.ui.info "To import it into vagrant type:"
          env.ui.info "vagrant box add '#{name}' '#{box_path}'"
          env.ui.info ""
          env.ui.info "To use it:"
          env.ui.info "vagrant init '#{name}'"
          env.ui.info "vagrant up"
          env.ui.info "vagrant ssh"
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
