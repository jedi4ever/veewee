mkdir /home/vagrant
chown vagrant /home/vagrant
cd /home/vagrant

# http://superuser.com/questions/40545/upgrading-and-installing-packages-through
-the-cygwin-command-line
wget http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
chmod +x apt-cyg
mv apt-cyg /usr/local/bin/

# Install virtualbox
wget http://download.virtualbox.org/virtualbox/4.0.8/VirtualBox-4.0.8-71778-Win.exe
chmod +x VirtualBox-4.0.8-71778-Win.exe
./VirtualBox-4.0.8-71778-Win.exe -extract -s -p .
msiexec /i VirtualBox-4.0.8-r71778-MultiArch_amd64.msi ALLUSERS=2

#https://github.com/opscode/knife-windows/blob/master/lib/chef/knife/bootstrap/windows-shell.erb

#Installing ruby
wget http://rubyforge.org/frs/download.php/74298/rubyinstaller-1.9.2-p180.exe
chmod +x rubyinstaller-1.9.2-p180.exe
./rubyinstaller-1.9.2-p180.exe /verysilent  /tasks="assocfiles,modpath" /SUPPRESSMSGBOXES /LOG="rubyinstaller.log"

#Ruby dev kit
wget --no-check-certificate  http://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe
mkdir /cygdrive/c/devkit
mv DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe /cygdrive/c/devkit/rubydevkit.exe
cd /cygdrive/c/devkit
chmod +x rubydevkit.exe
./rubydevkit -y
ruby dk.rb init
ruby dk.rb install

cd /cygdrive/c/devkit
./gem install win32-open3 rdp-ruby-wmi windows-api windows-pr --no-rdoc --no-ri --verbose
./gem install puppet  --no-rdoc --no-ri --verbose
./gem install chef  --no-rdoc --no-ri --verbose

# Reboot
# http://www.techrepublic.com/blog/datacenter/restart-windows-server-2003-from-the-command-line/245
#shutdown.exe /r /t 0 /c "Vagrant initial reboot"
