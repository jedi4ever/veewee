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
        :kickstart_timeout => "60",
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

Available definitions:

Definition Option               | Default                 | Provider
--------------------------------|-------------------------|-------------------------------------------
:params                         | empty                   | core
:cpu_count                      | 1 CPU                   | kvm, parallels, virtualbox, vmfusion
:memory_size                    | 256 MB of memory        | kvm, parallels, virtualbox, vmfusion
:video_memory_size              | 10 MB of video memory   | virtualbox
:iso_file                       | no ISO file mounted     | core, kvm, parallels, virtualbox, vmfusion
:iso_download_timeout           | 1000                    | unused
:iso_src                        | empty                   | core
:iso_md5                        | empty                   | core
:iso_sha1                       | empty                   | core
:iso_sha256                     | empty                   | core
:iso_download_instructions      | empty                   | core
:disk_size                      | 10240                   | kvm, virtualbox, vmfusion
:disk_format                    | VDI                     | kvm, virtualbox
:disk_variant                   | Standard                | virtualbox
:disk_count                     | 1                       | virtualbox
:os_type_id                     | uninitialised           | core, kvm, parallels, virtualbox, vmfusion
:boot_wait                      | uninitialised           | core
:boot_cmd_sequence              | empty                   | core
:kickstart_port                 | uninitialised           | core
:kickstart_timeout              | uninitialised           | core
:kickstart_file                 | uninitialised           | core
:ssh_login_timeout              | uninitialised           | kvm, parallels, virtualbox, vmfusion
:ssh_user                       | uninitialised           | core, kvm, parallels, virtualbox, vmfusion
:ssh_password                   | uninitialised           | core, kvm, parallels, virtualbox, vmfusion
:ssh_key                        | uninitialised           | core
:ssh_host_port                  | 2222                    | core, virtualbox
:ssh_guest_port                 | 22                      | virtualbox
:winrm_login_timeout            | 10000                   | virtualbox, vmfusion
:winrm_user                     | uninitialised           | core, virtualbox, vmfusion
:winrm_password                 | uninitialised           | core, virtualbox, vmfusion
:winrm_host_port                | 5985                    | core, virtualbox, vmfusion
:winrm_guest_port               | 5985                    | virtualbox
:sudo_cmd                       | uninitialised           | core
:shutdown_cmd                   | uninitialised           | core
:pre_postinstall_file           | empty                   | core
:postinstall_files              | empty                   | core
:postinstall_timeout            | 10000                   | unused
:floppy_files                   | empty                   | core, kvm, virtualbox, vmfusion
:use_hw_virt_ext                | unused                  | unused
:use_pae                        | unused                  | unused
:hostiocache                    | uninitialised           | virtualbox
:use_sata                       | true                    | virtualbox
:add_shares                     | empty                   | vmfusion
:vmdk_file                      | uninitialised           | vmfusion
:skip_iso_transfer              | false                   | core
:skip_nat_mapping               | false                   | virtualbox
:force_ssh_port                 | false                   | core

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

## Using Yaml for storing configuration

You can store definitions in `*.yml` files, loading them is as easy as:

    Veewee::Definition.declare_yaml(filename1, filename2 ...)

For example given those 3 files:

    .
    ├── definitions
    │   └── myubuntubox
    │       ├── definition.rb
    │       ├── definition.yml
    │       ├── 64bit.yml
    │       ├── 32bit.yml
    │       └── ...

And `definition.rb` with

    Veewee::Definition.declare_yaml('definition.yml', '64bit.yml')

Then veewee will read first `definition.yml` and `64bit.yml`, this way
it is possible to mix multiple possible combinations of systems,
versions, and architectures. All the configurations available in
`declare` are also valid in `*yml` files.

You can also mix options with file names like:

    Veewee::Definition.declare_yaml(
      {:cpu_count => '1'},
      filename1,
      {:ssh_user => 'vagrant'},
      filename2,
      ...
    )


## Up Next

[Veeweefile](veeweefile.md) can be used to define your own paths.
