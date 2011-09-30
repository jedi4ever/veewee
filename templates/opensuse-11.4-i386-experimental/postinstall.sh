#Inspired by https://github.com/fnichol/wiki-notes/wiki/Creating-An-openSUSE-11.3-x32-Vagrant-Box

date > /etc/vagrant_box_build_time

zypper --non-interactive refresh
# zypper --non-interactive up

# /sbin/shutdown -r now && exit
# Install VirtualBox Guest Additions
# Install some pre-requisites needed for the Guest Additions package and remove the system-installed package:
zypper --non-interactive install make gcc
zypper --non-interactive install kernel-default-devel
zypper --non-interactive remove virtualbox-ose-guest-kmp-default \
  virtualbox-ose-guest-tools xorg-x11-driver-virtualbox-ose

# Fix remote login
echo 'UseDNS no' >> /etc/ssh/sshd_config

#install ruby
zypper --non-interactive install ruby ruby-devel rubygems
gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc
sudo zypper --non-interactive refresh
sudo zypper --non-interactive up
#
#/sbin/shutdown -hP now && exit


#Installing vagrant keys
zypper --non-interactive install wget
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso
exit



sudo zypper --non-interactive refresh
sudo zypper --non-interactive up
sudo /sbin/shutdown -r now && exit
Install VirtualBox Guest Additions
Install some pre-requisites needed for the Guest Additions package and remove the system-installed package:
sudo zypper --non-interactive install make gcc
sudo zypper --non-interactive install kernel-default-devel
sudo zypper --non-interactive remove virtualbox-ose-guest-kmp-default \
  virtualbox-ose-guest-tools xorg-x11-driver-virtualbox-ose
Now mount the Guest Additions from the Devices -> Install Guest Additions VirtualBox menu. Next, mount the iso and install the additions:
sudo mkdir -p /media/cdrom
sudo mount /dev/cdrom /media/cdrom
(cd /media/cdrom && sudo sh VBoxLinuxAdditions.run)
sudo umount /media/cdrom
Note: The installer will complain about not finding "the X.Org or XFree86 Window System" which is fine and expected.
Remove the disk from the virtual drive by clicking the CD-ROM icon and choosing from the flyout menu.
Prepare SSH Configuration
Install the public key that Vagrant uses when SSHing into the virtual machine:
sudo zypper --non-interactive install curl
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
curl -o ~/.ssh/authorized_keys \
  https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub
chmod 0600 ~/.ssh/authorized_keys 
Edit the sshd configuration to prevent DNS resolution (speedup logins):
sudo bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"
Install Ruby, Chef, And Puppet
Thankfully, openSUSE comes with a decently up to date ruby (1.8.7) and a non-crippled rubygems (currently 1.3.7), so this is straight forward:
sudo zypper --non-interactive install ruby ruby-devel rubygems
Install the chef and puppet gems so they are ready for the provisioners:
sudo gem install chef --no-ri --no-rdoc
sudo gem install puppet --no-ri --no-rdoc
Update Message Of The Day
Modify the message of the day (to match the default Vagrant box):
sudo bash -c "echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd"
Final Cleanup
Run one last update and cleanup:
sudo zypper --non-interactive refresh
sudo zypper --non-interactive up
Finally, shutdown the virtual machine:
sudo /sbin/shutdown -hP now && exit
