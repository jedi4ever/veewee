module Veewee
  class Export

#    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})    
    
    def self.vagrant_box(boxname,boxdir)
      puts "To export the box you just created to vagrant, use the following commands:"
      puts "vagrant package --base '#{boxname}' --output #{boxname}.box'"
      puts ""
      puts "To import it into vagrant type:"
      puts "vagrant box add '#{boxname}' '#{boxname}.box'"
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
