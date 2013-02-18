# Veewee definitions

Veewee uses `definitions` to create new boxes. Every definition is based on a `template`.

A `template is represented by a sub-directory in the folder `templates`.

There you'll find all the templates you can use.

Each folder name follows a naming scheme to help you choosing the right template:

    <OS name>-<version>-<architecture>[-<install flavor>]

The template for a Ubuntu 12.10 server (i386) basebox looks like this:

    ubuntu-12.10-server-i386[-netboot]
                             ^ ----- install flavor
                        ^ ----- architecture
           ^ ----- version
    ^ ----- OS name


## List existing definitions

To list all available definitions run this command:

    veewee vbox list


## Listing available templates

Veewee provides templates for a lot of different Operation Systems.

To see all the templates provided:

    $ veewee vbox templates

Templates have the same structure as a <definition> but are provided by veewee as templates for definitions.

Definitions are *your* box templates.


## Creating a definition

A definition is created by 'cloning' a *template* into the `definitions` folder.

To create a definition you use the `define` subcommand:

    veewee vbox define 'myubuntubox' 'ubuntu-12.10-server-amd64'

If you want to use an external repo for the definition you can specify a git-url

    veewee vbox define 'myubuntubox' 'git://github.com/jedi4ever/myubuntubox'


## Remove a definition

If you change your mind and want to get rid of a definition simply call this command:

    veewee vbox undefine 'myubuntubox'

Or you can remove the folder under `definitions`:

    rm -r ./definitions/myubuntubox


## Example

Let's say you'd like to have a *Ubuntu 12.10 server (i386)* basebox.

Go and find the template `ubuntu-12.10-server-i386` within `templates` to verify you can create a definition.

Use the `veewee vbox define` command to create your definition with a custom name.

	IMPORTANT: You should avoid dots in the name because the boxname gets used as the hostname also.
	Dots in the boxname currently lead to invalid hostnames which causes several sideeffects eg. preventing the network devices to start.

The following command copies the folder `templates/ubuntu-12.10-server-i386` to `definitions/myubuntubox`:

    $ veewee vbox define 'myubuntubox' 'ubuntu-12.10-server-i386'
    The basebox 'myubuntubox' has been successfully created from the template 'ubuntu-12.10-server-i386'
    You can now edit the definition files stored in definitions/myubuntubox or build the box with:
    veewee vbox build 'myubuntubox'

Verify that all files are in place:

    $ ls definitions/myubuntubox
    definition.rb  postinstall.sh preseed.cfg

You now can inspect and modify the defaults to your needs (see below) or start building the box with this command:

    veewee vbox build 'myubuntubox'

Veewee now asks for downloading the ISO and will start his magic.


## Modify the definition (optional)

You can tweak and customize every detail of the box by modifying and extending the (sane) default settings
that come with a template.

If you want to modify these settings take a look at [customization instructions](customize.md).


## Getting the CD-ROM file in place

The [CD-ROM file](http://en.wikipedia.org/wiki/ISO_image) (also called `.iso` or *disk image* file)
provides all files needed to install the OS.

This file is essential for starting the installation process.

If you already have an `.iso` file for the desired distribution on your disk put it inside the `./iso` directory.

Create this directory if it does not exist. Otherwise Veewee will ask you to download the ISO file from the web.

Depending on your internet connection fetching a ISO file can take several minutes.


## Build the new box:

In order to build the box execute this command:

    $ veewee vbox build 'myubuntubox'

TIPP: If you already built a box with that name you can use `--force` to overwrite an existing installation.

The command will run the following routines behind the scenes:

- It will create a machine + disk according to the `definition.rb`
- Note: `:os_type_id` = The internal Name Virtualbox uses for that Distribution
- Mount the ISO File `:iso_file`
- Boot up the machine and wait for `:boot_time`
- Send the keystrokes in `:boot_cmd_sequence`
- Startup a webserver on `:kickstart_port` to wait for a request for the `:kickstart_file`
  IMPORTANT: Do NOT navigate to the file in your browser or the server will stop and the installer will not be able to find your preseed
- Wait for ssh login to work with `:ssh_user` and `:ssh_password`
- `sudo` execute the `:postinstall_files`


## Validate the vm

After the OS has been installed you can verify that the machine is configured as intended.

Veewee provides several tests to help you with that. The tests are located under `validation`.

This command executes all tests on the given machine:

    $ veewee vbox validate 'myubuntubox'

This will run some [cucumber test](http://cukes.info/) against the box
to see if it has the necessary bits and pieces e.g. for vagrant to work.


## Export the box for distribution

The following command take care of this:

    $ veewee vbox export 'mybuntubox'

The export format depends on the provider. You can currently choose from these providers:

- `fusion`: exports to an '.ova' file
- `kvm`: export to a raw '.img' file
- `vbox`: exports to a '.box' format (e.g. for use in vagrant)

For more details on the providers have a look at [providers.md](providers.md).