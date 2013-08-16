# Customizing Definitions

## Definition overview

Definitions are stored under the `definitions/` directory relative to the current directory.

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

* memory size
* number of CPUs
* user account and password
* sudo command
* shutdown command
* URL and checksum to download the ISO

When a new machine boots, it will typically fetch its initial configuration file over http from a _kickstart_ file defined in `kickstart_file`. These files are usually named `preseed.cfg` or `ks.cfg`.


## Postinstall scripts

You can define multiple postinstall files by providing an array of filenames within `definition.rb`, like so:

    :postinstall_files => [ "postinstall.sh",  "postinstall_2.sh" ],

Once the initial installation is done, Veewee will execute each postinstall `.sh` file on the machine in chronologic order (order found in :postinstall_files array).

The main reason for splitting up the original `postinstall.sh` script into multiple files is to make the post-install steps as reusable and portable as possible for different virtualization systems and/or operating systems. For example, there is no need to install the Virtualbox Guest Additions on KVM or VMware Fusion.


## Postinstall barebones

A definition usually consists of at least these postinstall files:

Filename        | Description
----------------|-------------
preseed.cfg     | Default options for the installer. See https://help.ubuntu.com/12.04/installation-guide/i386/preseed-using.html
definition.rb   | Core definition of a box; like CPU, RAM, and the commands for the initial boot sequence
postinstall.sh  | Steps that run _after_ installing the OS

Newer definitions contain of even more files (they have broken `postinstall.sh` into multiple files) to get a finer separation of concerns for the installation.


## Using ERB in files

Add `.erb` to your files in a definition and they will get parsed accordingly.

This is useful for generating kickstart, post-install at runtime.

Thanks to __@mconigilaro__ for the contribution!


## Configuring definition.rb

The `definition.rb` file is the core definition file of each box. All crucial properties and postinstall scripts are defined here.

The `boot_cmd_sequence` parameter allows you to override the initial commands (like keyboard layout) that are fired up in the first boot sequence.

All other settings are used internally by Veewee, the virtualization provider, or simply for choosing the proper ISO:

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

**IMPORTANT:** If you change values directly in a template, be sure to run `bundle exec veewee <provider> undefine` to remove the old definition and then `bundle exec veewee <provider> define` again to copy the updated template files into the definition.

If you are an experienced devops veteran and have enhanced template settings, please let us know why. We are very interested in improving Veewee's templates.


## Provider `vm_options`

Each provider _can_ take options that are specific the provider; more details will be available in each [provider](providers.md) doc but let's have a quick overview here:

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

This box will have `pae` and `ioapic` enabled with VirtualBox, and will use the `brlxc0` bridge with KVM (on libvirt).


## Up Next

[Veeweefile](veeweefile.md) can be used to define your own paths.
