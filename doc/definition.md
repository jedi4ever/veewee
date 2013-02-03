# Veewee definitions

Veewee uses `definitions` to create new boxes. Every definition is based on a `template`.

A `template is represented by a sub-directory in the folder `templates`.

There you'll find all the templates you can use.

Each folder name follows a naming scheme to help you choosing the right template:

    <OS name>-<version>-<architecture>[-<install flavor>]


## Creating a definition

A definition is created by 'cloning' a *template*.

To create a definition you use the `define` subcommand:

    veewee vbox define 'myubuntu' 'ubuntu-12.10-server-amd64'

If you want to use an external repo for the definition you can specify a git-url

    veewee vbox define 'myubuntu' 'git://github.com/jedi4ever/myubuntu'

## Modifying a definition

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

The file `definition.rb` contains all the parameters to define the machine to be build:

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


### Changes between v0.2 -> v0.3

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


### Using ERB in files

Add `.erb` to your files in a definition and they will get rendered.

This is useful for generating kickstart, post-install at runtime.

Thanks @mconigilaro for the contribution!


## List existing definitions

    veewee vbox list

## Remove a definition

    veewee vbox undefine 'myubuntu'

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
