# Running veewee

## Calling veewee

### Using veewee cli
The first way to call veewee is through the 'veewee' cli command:

    $ veewee
    Tasks:
      veewee fusion       # Subcommand for Vmware fusion
      veewee help [TASK]  # Describe available tasks or one specific task
      veewee kvm          # Subcommand for kvm
      veewee vbox         # Subcommand for virtualbox
      veewee version      # Prints the Veewee version information

### Using veewee as a vagrant plugin
The second way is to use it a vagrant plugin. Veewee registeres itself as a subcommand 'basebox'

    $ vagrant basebox
    Usage: vagrant basebox <command> [<args>]

    Available subcommands:
         build
         define
         destroy
         export
         halt
         list
         ostypes
         ssh
         templates
         undefine
         up

    For help on any individual command run `vagrant basebox COMMAND -h`

## Available commands

The following command are available: change the vbox to fusion or kvm if you want to use a different <provider>

    Tasks:
      veewee vbox build [BOX_NAME]             # Build box
      veewee vbox define [BOXNAME] [TEMPLATE]  # Define a new basebox starting fr...
      veewee vbox destroy [BOXNAME]            # Destroys the basebox that was built
      veewee vbox halt [BOXNAME]               # Activates a shutdown on the basebox
      veewee vbox help [COMMAND]               # Describe subcommands or one spec...
      veewee vbox list                         # Lists all defined boxes
      veewee vbox ostypes                      # List the available Operating Sys...
      veewee vbox ssh [BOXNAME] [COMMAND]      # Shows SSH information
      veewee vbox templates                    # List the currently available tem...
      veewee vbox undefine [BOXNAME]           # Removes the definition of a base...
      veewee vbox up [BOXNAME]                 # Starts a Box
      veewee vbox validate [NAME]              # Validates a box against vagrant ...

## Non-Vagrant usage
A typical cycle would be:

  $ veewee vbox define 'mybuntu' 'ubuntu-10.10-amd64'
  $ veewee vbox build 'myubuntu'
  $ veewee vbox ssh 'myubuntu'
  $ veewee vbox halt 'myubuntu'
  $ veewee vbox up 'myubuntu'
  $ veewee vbox export 'myubuntu'

## Vagrant usage

A typical cycle would be:

    $ vagrant basebox define 'myubuntu' 'ubuntu-10.10-amd64'
    $ vagrant basebox  build 'myubuntu'
    $ vagrant basebox  export 'myubuntu'

    $ vagrant basebox add 'myubuntu' 'myubuntu.box'
    $ vagrant init 'mybuntu'
    $ vagrant up
    $ vagrant ssh

## Exporting a vm
The export format depends on the provider:

- fusion : exports to an 'ova' file
- kvm : export to a raw '.img' file
- vbox: exports to a '.box' format (for use in vagrant)
