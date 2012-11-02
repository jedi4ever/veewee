REM set -x

REM # Create the home directory
REM mkdir -p /home/vagrant
REM chown vagrant /home/vagrant
REM cd /home/vagrant

REM # Install ssh certificates
REM mkdir /home/vagrant/.ssh
REM chmod 700 /home/vagrant/.ssh
REM cd /home/vagrant/.ssh
REM wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
REM chown -R vagrant /home/vagrant/.ssh
REM cd ..

REM # Install rpm,apt-get like code for cygwin
REM # http://superuser.com/questions/40545/upgrading-and-installing-packages-through-the-cygwin-command-line
REM wget http://apt-cyg.googlecode.com/svn/trunk/apt-cyg
REM chmod +x apt-cyg
REM mv apt-cyg /usr/local/bin/

REM # 7zip will allow us to extract a file from an ISO
REM wget http://downloads.sourceforge.net/sevenzip/7z922-x64.msi
REM msiexec /qb /i 7z922-x64.msi

REM # Download Virtualbox Additions
REM VBOX_VERSION="4.1.8" #"4.0.8"
REM wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

REM # Extract the installer from the ISO (WHY WHY WHY isn't this available not bundled within an ISO)
REM /cygdrive/c/Program\ Files/7-Zip/7z.exe x VBoxGuestAdditions_$VBOX_VERSION.iso VBoxWindowsAdditions-amd64.exe

REM # Mark Oracle as a trusted installer
REM #http://blogs.msdn.com/b/steverac/archive/2009/07/09/adding-certificates-to-the-local-certificates-store-and-setting-local-policy-using-a-command-line-system-center-updates-publisher-example.aspx

REM certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer

REM # Install the Virtualbox Additions
REM ./VBoxWindowsAdditions-amd64.exe /S


REM #Rather than do the manual install of ruby and chef, just use the opscode msi
cmd /C cscript %TEMP%\wget.vbs /url:http://www.opscode.com/chef/install.msi /path:%TEMP%\chef-client.msi
msiexec /qb /i %TEMP%\chef-client-latest.msi


REM #http://www.msfn.org/board/topic/105277-howto-create-a-fully-up-to-date-xp-x64-dvd/

REM #Making aliases
REM cat <<EOF > /home/vagrant/.bash_profile
REM alias chef-client="chef-client.bat"
REM alias gem="gem.bat"
REM alias ruby="ruby.exe"
REM alias puppet="puppet.bat"
REM alias ohai="ohai.bat"
REM alias irb="irb.bat"
REM alias facter="facter.bat" 
REM EOF


REM cat <<'EOF' > /bin/sudo
REM #!/usr/bin/bash
REM exec "$@"
REM EOF
REM chmod 755 /bin/sudo

REM # Mounting a directory
REM net.exe use  '\\vboxsvr\veewee-validation'


REM # Reboot
REM # http://www.techrepublic.com/blog/datacenter/restart-windows-server-2003-from-the-command-line/245
REM shutdown.exe /s /t 0 /d p:2:4 /c "Vagrant initial reboot"

