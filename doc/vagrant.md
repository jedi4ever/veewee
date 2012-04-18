## Define a new box
Let's define a  Ubuntu 10.10 server i386 basebox called myunbuntubox
this is essentially making a copy based on the  templates provided above.

    $ veewee vbox define 'myubuntubox' 'ubuntu-10.10-server-i386'
    The basebox 'myubuntubox' has been succesfully created from the template ''ubuntu-10.10-server-i386'
    You can now edit the definition files stored in definitions/myubuntubox
    or build the box with:
    veewee vbox build 'myubuntubox'

-> This copies over the templates/ubuntu-10.10-server-i386 to definition/myubuntubox

    $ ls definitions/myubuntubox
    definition.rb	postinstall.sh	postinstall2.sh	preseed.cfg

## Optionally modify the definition.rb , postinstall.sh or preseed.cfg

    Veewee::Definition.declare( {
    :cpu_count => '1', :memory_size=> '256', 
    :disk_size => '10140', :disk_format => 'VDI',
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

If you need to change values in the templates, be sure to run the rake undefine, the rake define again to copy the changes across.

## Getting the cdrom file in place
Put your isofile inside the 'currentdir'/iso directory or if you don't run

    $ veewee vbox build 'myubuntubox'

- the build assumes your iso files are in 'currentdir'/iso
- if it can not find it will suggest to download the iso for you
- use '--force' to overwrite an existing install

## Build the new box:

    $ veewee vbox build 'myubuntubox'

- This will create a machine + disk according to the definition.rb
- Note: :os_type_id = The internal Name Virtualbox uses for that Distribution
- Mount the ISO File :iso_file
- Boot up the machine and wait for :boot_time
- Send the keystrokes in :boot_cmd_sequence
- Startup a webserver on :kickstart_port to wait for a request for the :kickstart_file (don't navigate to the file in your browser or the server will stop and the installer will not be able to find your preseed)
- Wait for ssh login to work with :ssh_user , :ssh_password
- Sudo execute the :postinstall_files

## Validate the vm 

    $ veewee vbox validate 'myubuntubox'

this will run some cucumber test against the box to see if it has the necessary bits and pieces for vagrant to work

## Export the vm to a .box file

    $ vagrant basebox export 'myubuntubox'

this is actually calling - vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'

this will result in a myubuntubox.box

## Add the box as one of your boxes
To import it into vagrant type:

    $ vagrant box add 'myubuntubox' 'myubuntubox.box'

## Use it in vagrant

To use it:

    $ vagrant init 'myubuntubox'
    $ vagrant up
    $ vagrant ssh

## How to add a new OS/installation (needs some love)

I suggest the easiest way is to get an account on github and fork of the veewee repository

    $ git clone https://github.com/*your account*/veewee.git
    $ cd veewee
    $ gem install bundler
    $ bundle install

If you don't use rvm, be sure to execute vagrant through bundle exec

    $ alias vagrant="bundle exec vagrant"

Start of an existing one

    $ veewee vbox define 'mynewos' 'ubuntu...'

- Do changes in the currentdir/definitions/mynewos
- When it builds ok, move the definition/mynewos to a sensible directory under templates
- commit the changes (git commit -a)
- push the changes to github (git push)
- go to the github gui and issue a pull request for it

## If you have a setup working, share your 'definition' with me. That would be fun! 
