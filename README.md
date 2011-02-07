**VeeWee:** the tool to easily build vagrant base boxes
Vagrant is a great tool to test new things or changes in a virtual machine(Virtualbox) using either chef or puppet.
The first step is to download an existing 'base box'. I believe this scares a lot of people as they don't know who or how this box was build. Therefore lots of people end up first building their own base box to use with vagrant.

Veewee tries to automate this and to share the knowledge and sources you need to create a basebox. Instead of creating custom ISO's from your favorite distribution, it leverages the 'keyboardputscancode' command of Virtualbox so send the actual 'boot prompt' keysequence to boot an existing iso.

Before we can actually build the boxes, we need to take care of the minimal things to install:
- Have Virtualbox 4.x installed -> download it from http://download.virtualbox.org/virtualbox/


ALPHA CODE: -> you're on your own....

## Installation: 
__from source__
$ git clone https://github.com/jedi4ever/veewee.git
$ cd veewee
$ gem install bundler
$ bundle install

__as a gem__
$ gem install veewee


## List all templates
$ vagrant basebox templates

## Define a new box (ex. Ubuntu 10.10 server i386)

this is essentially making a copy based on the  templates provided above.

$ vagrant basebox define 'myubuntubox' 'ubuntu-10.10-server-i386'
template successfully copied

-> This copies over the templates/ubuntu-10.10-server-i386 to definition/myubuntubox

$ ls definitions/myubuntubox
definition.rb	postinstall.sh	postinstall2.sh	preseed.cfg

## Optionally modify the definition.rb , postinstall.sh or preseed.cfg

<pre>
Veewee::Session.declare( {
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI',:disk_size => '10240' ,
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-10.10-server-i386.iso", 
  :iso_src => "http://releases.ubuntu.com/maverick/ubuntu-10.10-server-i386.iso",
  :iso_md5 => "ce1cee108de737d7492e37069eed538e",
  :iso_download_timeout => "1000",
  :boot_wait => "10",
  :boot_cmd_sequence => [ 
      '<Esc><Esc><Enter>',
      '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
      'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
      'hostname=%NAME% ',
      'fb=false debconf/frontend=noninteractive ',
      'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
      'initrd=/install/initrd.gz -- <Enter>' 
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "2222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -H",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
</pre>

If you need to change values in the templates, be sure to run the rake undefine, the rake define again to copy the changes across.

## Put your isofile inside the $VEEWEE/iso directory or if you don't run
$ vagrant basebox build 'myubuntubox'

-> the build assumes your iso files are in 'currentdir'/iso
-> if it can not find it will suggest to download the iso for you

## Build the new box:
$ vagrant basebox build 'myubuntubox'

- This will create a machine + disk according to the definition.rb
- Note: :os_type_id = The internal Name Virtualbox uses for that Distribution
- Mount the ISO File :iso_file
- Boot up the machine and wait for :boot_time
- Send the keystrokes in :boot_cmd_sequence
- Startup a webserver on :kickstart_port to wait for a request for the :kickstart_file
- Wait for ssh login to work with :ssh_user , :ssh_password
- Sudo execute the :postinstall_files

## Export the vm to a .box file
$ vagrant basebox export 'myubuntubox' 

this is actually calling - vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'

this will result in a myubuntubox.box

## Add the box as one of your boxes
vagrant box add 'myubuntubox' 'myubuntubox.box'

## Use it in vagrant
Start vagrant init in another window (as we have set the Virtualbox env to tmp before)
$ To import it into vagrant type:

To use it:
vagrant init 'myubuntubox'
vagrant up
vagrant ssh

## If you have a setup working, share your 'definition' with me. That would be fun! 

IDEAS:

- Now you integrate this with your CI build to create a daily basebox

FUTURE IDEAS:

- use snapshots to fastforward initial boot, and every postinstall command
- export to AMI too
- provide for more failsafe execution, testing parameters
- use more virtualbox ruby instead of calling the VBoxManage command
- Verify the installation with cucumber-nagios (ssh functionality)
- Do the same for Vmware Fusion

BUGS: Lots = Like I said it currently works for me, on my machine and with the correct magic sequence :)
