# Customize Veewee Definitions

Definitions are stored under a directory 'definitions' relative to the current directory.

    .
    ├── definitions
    │   └── myubuntubox
    │       ├── <preseed.cfg, kickstart.cfg, ...>
    │       ├── base.sh
    │       ├── cleanup.sh
    │       ├── chef.sh
    │       ├── puppet.sh
    │       ├── ruby.sh
    │       ├── virtualbox.sh
    │       └── ....sh
    └── README.md

The file `definition.rb` contains all the parameters to define the machine to be build (see below):

  - memorysize
  - number of cpus
  - user account and password
  - sudo command
  - shutdown command
  - URL and checksum to download the ISO

When a new machine boots, it will typically fetch its initial configuration file over http from a _kickstart_ file
defined in `kickstart_file`. These files are usually named `preseed.cfg` or `ks.cfg`.

You can define multiple files by providing an array of filenames:

    :postinstall_files => [ "postinstall.sh",  "postinstall_2.sh" ],

Once the initial installation is done, veewee will execute each `.sh` file on the machine.

INFO: The main reason for splitting up the `postinstall.sh` we used to have, is to make the steps more reusable
for different virtualization systems. For example there is no need to install the Virtualbox Guest Additions
on kvm or VMware Fusion.


### Using ERB in files

Add `.erb` to your files in a definition and they will get rendered.

This is useful for generating kickstart, post-install at runtime.

Thanks @mconigilaro for the contribution!

A definition usually consists of these files:

    definition.rb   - Core definition of a box like CPU, RAM and the commands for the initial boot sequence
    postinstall.sh  - Steps that run 'after' installing the OS
    preseed.cfg     - Default options for the installer. See https://help.ubuntu.com/12.04/installation-guide/i386/preseed-using.html

Newer definitions contain of even more files to get a finer separation of concerns for the installation.


## definition.rb

The core definition of a box. All crucial properties are defined here.

The `boot_cmd_sequence` is probably the most interesting because it allows you to override the initial commands
(like keyboard layout) that are fired up in the first boot sequence.

All other settings are used internally by veewee, the virtualization tool or simply for choosing the right ISO:

    Veewee::Definition.declare( {
        :cpu_count => '1',
        :memory_size=> '256',
        :disk_size => '10140',
        :disk_format => 'VDI',
        :disk_variant => 'Standard',
        :os_type_id => 'Ubuntu',
        :iso_file => "ubuntu-12.10-server-i386.iso",
        :iso_src => "http://releases.ubuntu.com/precise/ubuntu-12.10-server-i386.iso",
        :iso_md5 => "3daaa312833a7da1e85e2a02787e4b66",
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
        :kickstart_port => "7122",
        :kickstart_timeout => "10000",
        :kickstart_file => "preseed.cfg",
        :ssh_login_timeout => "10000",
        :ssh_user => "vagrant",
        :ssh_password => "vagrant",
        :ssh_key => "",
        :ssh_host_port => "2222", :ssh_guest_port => "22",
        :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
        :shutdown_cmd => "shutdown -H",
        :postinstall_files => [ "postinstall.sh"],
        :postinstall_timeout => "10000"
    })

IMPORTANT: If you need to change values in the templates, be sure to run `veewee vbox undefine` to remove the old definition and then `veewee vbox define` again to copy the updated template files into the definition.

PRO Tip: If you change template settings please let us know why. We are very interested in improving the templates.


## Provider `vm_options`

Each provider _can_ take options that are specific to them; more details will
be available in each provider documentation but let's have a quick overview:

    Veewee::Definition.declare({
        :cpu_count => '1',
        :memory_size => '256',
        :disk_size => '10140',
        :disk_format => 'VDI',
        :disk_variant => 'Standard',
        # […]
        :postinstall_files => [ "postinstall.sh" ],
        :postinstall_timeout => "10000",
        :kvm => {
            :vm_options => [
                'network_type' => 'bridge',
                'network_bridge_name' => 'brlxc0'
            ]
        },
        :virtualbox => {
            :vm_options => [
                'pae' => 'on',
                'ioapic' => 'one'
            ]
        }
    })

This box will have `pae` and `ioapic` enabled on Virtualbox, and will use
the `brlxc0` bridge on with kvm (on libvirt).


## Changes between v0.2 -> v0.3

1. The `Veewee::Session.declare` is now _deprecated_ and you should use `Veewee::Definition.declare`.
   'Postinstall_files' prefixed with an _underscore_ are not executed by default:
       .
       ├── definitions
       │   └── myubuntubox
       │       ├── _postinstall.sh    # NOT executed
       │       ├── postinstall_2.sh   # GETS executed
   You can enforce including or excluding files with the `--include` and `--exclude` flag when using the `<build>` command.
   This allows you to use different scripts for installing ruby or to disable the installation of puppet or chef.
2. The default user of definitions is now 'veewee' and not 'vagrant'.
   This is because on other virtualizations like fusion and `kvm`, there is not relationship with the 'vagrant'.
   The User 'vagrant' is created by the `vagrant.sh` script and not by the preseed or kickstart file.
