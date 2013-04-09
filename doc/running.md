# Running veewee commands

The first way to call veewee is through the `veewee` cli command.

Simply type `veewee` to get a list for the basic commands:

    $ veewee
    Tasks:
      veewee fusion       # Subcommand for Vmware fusion
      veewee help [TASK]  # Describe available tasks or one specific task
      veewee kvm          # Subcommand for kvm
      veewee vbox         # Subcommand for virtualbox
      veewee version      # Prints the Veewee version information

Each of these commands provides more details if you execute them.

The following command gives you a list of all available subcommands:

    veewee vbox

Change `vbox` to `fusion` or `kvm` if you want to use a different provider.


## Typical Usage

A typical workflow to build a new basebox with veewee would be:

    1. Define a box definition from a template
    2. Build the box from an ISO file
    3. Export the box e.g. for distribution

The following commands take care of this:

    $ veewee vbox define 'mybuntubox' 'ubuntu-10.12-amd64'
    $ veewee vbox build 'mybuntubox'
    $ veewee vbox export 'mybuntubox'

The export format depends on the provider. You can currently choose from these providers:

- `fusion`: exports to an '.ova' file
- `kvm`: export to a raw '.img' file
- `vbox`: exports to a '.box' format (e.g. for use in vagrant)

If you want to tweak things on the box you can login to the box with this command:

    $ veewee vbox ssh 'mybuntubox'

PRO TIP: Be aware that every manual change on the box is considered harmful.
Have a look at [customize.md](customize.md) to see how you can customize the box in a more 'reproducible' way.


## Using veewee as a Vagrant Plugin

You can also use veewee as a [vagrant plugin](http://docs.vagrantup.com/v1/docs/plugins.html).

Veewee introduces the subcommand `basebox` on top of the `vagrant` command:

    $ vagrant basebox
    Usage: vagrant basebox <command> [<args>]

This allows you to use the 'vagrant' command style, which may feel more natural
if you are already working with vagrant.


### Typical Vagrant Usage

See "[Use it in vagrant](vagrant.md)" for more details.

## Debugging

Set the VEEWEE_LOG environment variable to "debug" to get full debug logging.
