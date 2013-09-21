# Veewee

[![Build Status](https://travis-ci.org/jedi4ever/veewee.png)](https://travis-ci.org/jedi4ever/veewee)

Veewee is a tool for easily (and repeatedly) building custom [Vagrant](https://github.com/mitchellh/vagrant) base boxes, KVMs, and virtual machine images.


## About Vagrant

Vagrant is a great tool for creating and configuring lightweight, reproducible, portable virtual machine environments - often used with the addition of automation tools such as [Chef](https://github.com/opscode/chef) or [Puppet](https://github.com/puppetlabs/puppet).

The first step to build a new virtual machine is to download an existing 'base box'. I believe this scares a lot of people as they don't know how these unverified boxes were built. Therefore a lot of people end up building their own base box which is often time consuming and cumbersome. Veewee aims to automate all the steps for building base boxes and to collect best practices in a transparent way.


## Veewee's Supported VM Providers

Veewee isn't only for Vagrant.  It currently supports exporting VM images for the following providers:

* [VirtualBox](http://www.virtualbox.org/) - exports to `OVF` filetype
* [VMware (Fusion)](http://www.vmware.com/products/fusion/) - exports to `OVA` filetype
* [KVM](http://www.linux-kvm.org/) - exports to `IMG` filetype
* [Parallels](http://www.parallels.com/) - none yet, but can export to `parallels` format (provided by [vagrant-parallels](https://github.com/yshahin/vagrant-parallels))


## Getting Started

Before you start, we recommend reading through these pages:

* [Requirements](doc/requirements.md) that must be met before installing Veewee
* [Veewee Installation](doc/installation.md) instructions
* [Command Options](doc/commands.md) highlights various approaches for executing Veewee on the command line

Next, learn about Veewee fundamentals:

* [Veewee Basics](doc/basics.md) covers creating standard-issue boxes
* [Customizing Definitions](doc/customize.md) helps you fine tune each box definition to meet your exact needs
* [Veeweefile](doc/veeweefile.md) can be used to define your own paths

Then depending on how you want to use Veewee, we suggest to read through one of the following guides:

* [Guide for Vagrant](doc/vagrant.md)
* [Guide for VirtualBox](doc/vbox.md)
* [Guide for VMware Fusion](doc/fusion.md)
* [Guide for KVM](doc/kvm.md)
* [Guide for Parallels Desktop](doc/parallels.md)

Major noteworthy changes between versions can be found here:

* [Changes](doc/changes.md) between versions

A complete list of all docs can be found by viewing the [doc directory](doc).


## Veewee Commands

Below is an overview of the `veewee` command options:

    $ bundle exec veewee

    # Commands:
    #   veewee add_share       # Adds a Share to the Guest
    #   veewee fusion          # Subcommand for Vmware fusion
    #   veewee help [COMMAND]  # Describe available commands or one specific command
    #   veewee kvm             # Subcommand for KVM
    #   veewee parallels       # Subcommand for Parallels
    #   veewee vbox            # Subcommand for VirtualBox
    #   veewee version         # Prints the Veewee version information

Learn how to avoid typing `bundle exec` by visiting the [Commands](doc/commands.md) doc.


## Veewee Provider Subcommands

Below is an overview of the `veewee` provider subcommand options:

    $ bundle exec veewee <provider>

    # Commands:
    #   veewee <provider> build [BOX_NAME]                 # Build box
    #   veewee <provider> copy [BOXNAME] [SRC] [DST]       # Copy a file to the VM
    #   veewee <provider> define [BOXNAME] [TEMPLATE]      # Define a new basebox starting from a template
    #   veewee <provider> destroy [BOXNAME]                # Destroys the basebox that was built
    #   veewee <provider> halt [BOXNAME]                   # Activates a shutdown on the basebox
    #   veewee <provider> help [COMMAND]                   # Describe subcommands or one specific subcommand
    #   veewee <provider> list                             # Lists all defined boxes
    #   veewee <provider> ostypes                          # List the available Operating System types
    #   veewee <provider> screenshot [NAME] [PNGFILENAME]  # Takes a screenshot of the box
    #   veewee <provider> ssh [BOXNAME] [COMMAND]          # Interactive ssh login
    #   veewee <provider> templates                        # List the currently available templates
    #   veewee <provider> undefine [BOXNAME]               # Removes the definition of a basebox
    #   veewee <provider> up [BOXNAME]                     # Starts a Box
    #   veewee <provider> validate [NAME]                  # Validates a box against vagrant compliancy rules
    #   veewee <provider> winrm [BOXNAME] [COMMAND]        # Execute command via winrm


## Contribute

People have reported good experiences, why don't you give it a try?

If you have a setup working, share your 'definition' with me. That would be fun!

See [CONTRIBUTE.md](CONTRIBUTE.md).

