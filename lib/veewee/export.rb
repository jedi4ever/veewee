require 'pathname'
module Veewee
  class Export

#    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})    
    
    def self.vagrant(boxname,boxdir,definition)
      
      #Check if box already exists
      vm=VirtualBox::VM.find(boxname)
      if vm.nil?
        puts "#{boxname} is not found, maybe you need to build first?"
        exit
      end
      #We need to shutdown first
      if vm.running?
        puts "Vagrant requires the box to be shutdown, before it can export"
        puts "Sudo also needs to work for user #{definition[:ssh_user]}"
        puts "Performing a clean shutdown now."
        ssh_options={ :user => definition[:ssh_user], :port => definition[:ssh_host_port], :password => definition[:ssh_password],
            :timeout => definition[:ssh_timeout]}       
                    
        Veewee::Ssh.execute("localhost","sudo #{definition[:shutdown_cmd]}",ssh_options)

        #Wait for state poweroff
        while (vm.running?) do 
          print '.'
          sleep 1
        end
        puts
        puts "Machine #{boxname} is powered off cleanly"
      end

      #Vagrant requires a relative path for output of boxes
  
      #4.0.x. not using boxes as a subdir
      boxdir=Pathname.new(Dir.pwd)
      
      full_path=File.join(boxdir,boxname+".box")
      path1=Pathname.new(full_path)
      path2=Pathname.new(Dir.pwd)
      box_path=path1.relative_path_from(path2).to_s
      
      if File.exists?("#{box_path}")
        puts "box #{boxname}.box already exists"
        exit
      end
      
      puts "Executing vagrant voodoo:"
      export_command="vagrant package --base '#{boxname}' --output '#{box_path}'"
      puts "#{export_command}"
      Veewee::Shell.execute("#{export_command}") #hmm, needs to get the gem_home set?
      puts
      
      #add_ssh_nat_mapping back!!!!      
      
      puts "To import it into vagrant type:"
      puts "vagrant box add '#{boxname}' '#{box_path}'"
      puts ""
      puts "To use it:"
      puts "vagrant init '#{boxname}'"
      puts "vagrant up"
      puts "vagrant ssh"
    end
 
  end
end


#      #currently vagrant has a problem with the machine up, it calculates the wrong port to ssh to poweroff the system
#      thebox.execute("shutdown -h now") 
#      thebox.wait_for_state("poweroff")
         
#      Shellutil.execute("echo 'Vagrant::Config.run do |config|' > /tmp/Vagrantfile")    
#      Shellutil.execute("echo '   config.ssh.forwarded_port_key = \"ssh\"' >> /tmp/Vagrantfile")    
#      Shellutil.execute("echo '   config.vm.forward_port(\"ssh\",22,#{host_port})' >> /tmp/Vagrantfile")    
#      Shellutil.execute("echo 'end' >> /tmp/Vagrantfile") 

 
#vagrant export disables the machine
#      thebox.ssh_enable_vmachine({:hostport => host_port , :guestport => 22} )
