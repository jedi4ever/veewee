require 'pathname'
module Veewee
  class Export

#    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})    
    
    def self.vagrant(boxname,boxdir)
      
      #Check if box already exists
      
      #We need to shutdown first
      
      #Wait for state poweroff
      #Vagrant requires a relative path for output of boxes
      full_path=File.join(boxdir,boxname+".box")
      path1=Pathname.new(full_path)
      path2=Pathname.new(Dir.pwd)
      box_path=path1.relative_path_from(path2).to_s
      puts "To export the box you just created to vagrant, use the following commands:"
      puts "vagrant package --base '#{boxname}' --output '#{box_path}'"
      puts ""
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