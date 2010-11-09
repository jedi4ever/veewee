    thebox.transaction("latest updates", {:checksum => "fixedssh"}) do
        thebox.execute("yum -y update ")        
        thebox.execute("yum -y upgrade") 
        #to have the new kernel installed , we need to reboot
        thebox.execute("shutdown -h now") 
        thebox.wait_for_state("poweroff")
        thebox.up 
        thebox.when_ssh_login_works(sudoparams) do
             Shellutil.comment("ssh login works, let us get on with it")
         end 
    end     
    

   Shellutil.comment("installing ruby enterprise") 
   thebox.transaction("enterprise ruby installed") do
      thebox.execute("yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel")        
      #thebox.execute("echo vagrant | sudo -S apt-get -y install zlib1g-dev libssl-dev libreadline5-dev")        
      thebox.execute("wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz")        
      thebox.execute("tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz ")        
      thebox.execute("./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby")        
      thebox.execute("echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/rubyenterprise.sh")        
 end

   Shellutil.comment("installing chef") 
   thebox.transaction("chef gem installed") do
     thebox.execute("/opt/ruby/bin/gem install chef")        
    end

   Shellutil.comment("making the box vagrant ready") 
   thebox.transaction("vagrant ready",{:checksum => Time.now.hash.to_s }) do
     thebox.execute("useradd vagrant; mkdir /home/vagrant/.ssh; cd /home/vagrant/.ssh ;"+
     " wget \'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub\' -O authorized_keys; chown -R vagrant /home/vagrant ")
     thebox.execute("yum -y install kernel-devel kernel-headers")           
     thebox.mount_dvd("/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso")
     thebox.execute("mount /dev/dvd /mnt")
     thebox.execute("sh /mnt/VBoxLinuxAdditions-x86.run")
   end    
   
   Shellutil.comment("exporting the vagrant box #{vmname}") 
   thebox.transaction("vagrant export",{:checksum => Time.now.hash.to_s }) do
     
      #currently vagrant has a problem with the machine up, it calculates the wrong port to ssh to poweroff the system
      thebox.execute("shutdown -h now") 
      thebox.wait_for_state("poweroff")
         
      Shellutil.execute("echo 'Vagrant::Config.run do |config|' > /tmp/Vagrantfile")    
      Shellutil.execute("echo '   config.ssh.forwarded_port_key = \"ssh\"' >> /tmp/Vagrantfile")    
      Shellutil.execute("echo '   config.vm.forward_port(\"ssh\",22,#{host_port})' >> /tmp/Vagrantfile")    
      Shellutil.execute("echo 'end' >> /tmp/Vagrantfile") 
      Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})    

      #vagrant export disables the machine
      thebox.ssh_enable_vmachine({:hostport => host_port , :guestport => 22} )

    end
   
   #vagrant box add ubuntu package.box
   #vagrant init ubuntu
   #vagrant up
   #vagrant ssh
  

