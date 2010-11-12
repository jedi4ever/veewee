#Updating the box
apt-get -y update
#apt-get -y upgrade

#Shellutil.comment("installing ruby enterprise")
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev

wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/rubyenterprise.sh

/opt/ruby/bin/gem install chef

mkdir $HOME/.ssh; cd .ssh ;
wget 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys

#/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
#echo vagrant|sudo -S mount /dev/dvd /mnt
#echo vagrant|sudo -S sh /mnt/VBoxLinuxAdditions-x86.run

exit
currently vagrant has a problem with the machine up, it calculates the wrong port to ssh to poweroff the system      
thebox.execute("echo vagrant| sudo -S shutdown -h now")
      thebox.wait_for_state("poweroff")
      Shellutil.execute("echo 'Vagrant::Config.run do |config|' > /tmp/Vagrantfile")
      Shellutil.execute("echo '   config.ssh.forwarded_port_key = \"ssh\"' >> /tmp/Vagrantfile") 
      Shellutil.execute("echo '   config.vm.forward_port(\"ssh\",22,#{host_port})' >> /tmp/Vagran
tfile")
      Shellutil.execute("echo 'end' >> /tmp/Vagrantfile")
      Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tm
p/#{vmname}.box", {:progress => "on"})

      #vagrant export disables the machine
      thebox.ssh_enable_vmachine({:hostport => host_port , :guestport => 22} )

    end
   #vagrant box add ubuntu package.box
   #vagrant init ubuntu
   #vagrant up
   #vagrant ssh

