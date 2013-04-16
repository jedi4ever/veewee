# Major Changes

## Changes between v0.2 -> v0.3

1. The `Veewee::Session.declare` is now _deprecated_ and you should use `Veewee::Definition.declare`.
   'postinstall_files' prefixed with an _underscore_ are not executed by default:

    ~~~ sh
    .
    ├── definitions
    │   └── myubuntubox
    │       ├── _postinstall.sh    # NOT executed
    │       ├── postinstall_2.sh   # GETS executed
    ~~~

   You can enforce including or excluding files with the `--include` and `--exclude` flag when using the `build` command. This allows you to use different scripts for installing ruby or to disable the installation of puppet or chef.

2. The default user of definitions is now `veewee` and not `vagrant`.
   This is because on other VMs like `fusion` and `kvm`, there is no relationship with the `vagrant` user.
   The `vagrant` user is created by the `vagrant.sh` script and not by the _preseed_ or _kickstart_ files.