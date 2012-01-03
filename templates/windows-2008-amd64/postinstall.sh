# Create the home directory
mkdir /home/vagrant
chown vagrant /home/vagrant
cd /home/vagrant

# Install ssh certificates
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh
cd ..

# Install rpm,apt-get like code for cygwin
# http://superuser.com/questions/40545/upgrading-and-installing-packages-through-the-cygwin-command-line
wget http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
chmod +x apt-cyg
mv apt-cyg /usr/local/bin/

# 7zip will allow us to extract a file from an ISO
wget http://downloads.sourceforge.net/sevenzip/7z920-x64.msi
msiexec /qb /i 7z920-x64.msi

# Download Virtualbox Additions
VBOX_VERSION="4.1.8" #"4.0.8"
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

# Extract the installer from the ISO (WHY WHY WHY isn't this available not bundled inside an ISO)
7z.exe x VBoxGuestAdditions_$VBOX_VERSION.iso VBoxWindowsAdditions-amd64.exe

# Mark Oracle as a trusted installer
#http://blogs.msdn.com/b/steverac/archive/2009/07/09/adding-certificates-to-the-local-certificates-store-and-setting-local-policy-using-a-command-line-system-center-updates-publisher-example.aspx

certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer

# Install the Virtualbox Additions
./VBoxWindowsAdditions.exe /S


curl -L http://www.opscode.com/chef/install.msi -o chef-client-latest.msi
msiexec /qb /i chef-client-latest.msi

#http://www.msfn.org/board/topic/105277-howto-create-a-fully-up-to-date-xp-x64-dvd/

# Next step is get ruby working
# But thanks to opscode's work , that should not be an issue
# https://github.com/opscode/knife-windows/blob/master/lib/chef/knife/bootstrap/windows-shell.erb

#Installing ruby
cd /home/vagrant

# Ruby 1.9
#wget http://rubyforge.org/frs/download.php/74298/rubyinstaller-1.9.2-p180.exe -O rubyinstaller.exe
# Ruby 1.8
##wget http://files.rubyforge.vm.bytemark.co.uk/rubyinstaller/rubyinstaller-1.8.7-p334.exe -O rubyinstaller.exe

#chmod +x rubyinstaller.exe
#./rubyinstaller.exe /verysilent /dir="C:\ruby" /tasks="assocfiles,modpath" /SUPPRESSMSGBOXES

# Now add it to the path cmd, and cygwin path
# http://serverfault.com/questions/63017/how-do-i-modify-the-system-path-in-windows-2003-windows-2008-using-a-script
##/cygdrive/c/Windows/System32/setx.exe  PATH "c:\windows\system32;c:\ruby\bin" /M
##export PATH=$PATH:/cygdrive/c/ruby/bin

# Install Ruby dev kit (native extensions)
##mkdir /cygdrive/c/devkit
##cd /cygdrive/c/devkit
##wget --no-check-certificate  http://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe -O rubydevkit.exe
##chmod +x rubydevkit.exe
##./rubydevkit -y
##ruby dk.rb init
##ruby dk.rb install

# Installing puppet
##gem.bat install puppet  --no-rdoc --no-ri --verbose

# Installing chef required gems on windows
# For ruby 1.8
##gem.bat install win32-open3 ruby-wmi windows-api windows-pr --no-rdoc --no-ri --verbose
# For ruby 1.9
#gem.bat install win32-open3 rdp-ruby-wmi windows-api windows-pr --no-rdoc --no-ri --verbose

# Install chef
##gem.bat install ohai --no-rdoc --no-ri --verbose
##gem.bat install chef  --no-rdoc --no-ri --verbose

# Currently 1.9 ruby + chef 10 doesn't seem to be able to 
#http://stackoverflow.com/questions/4819807/ohai-fails-to-determine-os-version-in-cygwin



#Making aliases
cat <<EOF > /home/vagrant/.bash_profile
alias chef-client="chef-client.bat"
alias gem="gem.bat"
alias ruby="ruby.exe"
alias puppet="puppet.bat"
alias ohai="ohai.bat"
alias irb="irb.bat"
alias facter="facter.bat" 
EOF

# Reboot
# http://www.techrepublic.com/blog/datacenter/restart-windows-server-2003-from-the-command-line/245
shutdown.exe /r /t 0 /c "Vagrant initial reboot"

# Mounting a directory
#./net.exe use  x: \\vboxsvr\veewee-validation

