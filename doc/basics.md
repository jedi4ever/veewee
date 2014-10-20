# Veewee Basics

Veewee uses definitions to build new virtual machines. And every 'definition' is derived from a 'template'.

A template is represented by a sub-directory in the `templates/` folder. There you'll find many preconfigured templates.  With a single template you can spawn any number of customizable defintions.


## Template naming scheme

Each template folder name follows a naming scheme to help you choosing the right template:

    <OS name>-<version>-<architecture>[-<install flavor>]

For example, the template for a Ubuntu 12.10 server (i386) basebox looks like this:

    ubuntu-12.10-server-i386[-netboot]
    ^       ^           ^     ^
    |       |           |     +----- install flavor
    |       |           +----- architecture
    |       +----- version
    +----- OS name


## Typical usage

A common workflow to build a new base box with Veewee is:

1. List all templates to find a single template to use
2. Define a new box definition from a selected template
3. [Customize](customize.md) the definition (optional)
4. Build a VM using standard ISOs, your own definition settings, and some postinstall scripts
5. Validate the new VM
6. Manually alter the VM by logging in with ssh (optional; but not recommended)
7. Export the VM for distribution or to be used in Vagrant


## Getting help

If you'd like some help with a particular command:

    $ bundle exec veewee help <command>

And if you're not sure how to use a subcommand, get help with:

    $ bundle exec veewee <provider> help <subcommand>

The subcommand help is often useful since it will list available optional flag arguments.


## List existing definitions

To list all available definitions that you've previously created or copied:

    $ bundle exec veewee <provider> list


## Listing available templates

Veewee provides templates for a lot of different operation systems. To see all the templates provided:

    $ bundle exec veewee <provider> templates

Templates have the same structure as definitions, but templates are used to generate definitions. Definitions are simply **your** customizable templates that you can modify as you see fit.

### Template sources

Veewee will detect all gems with `veewee-templates` gemspec `metadata` pointing to templates directory:

```ruby
  spec.metadata = {
    "veewee-templates" => "templates"
  }
```

For example see [veewee.gemspec](../veewee.gemspec).

## Create a definition

A definition is created by cloning a template into the `definitions/` folder.

To create a definition, use the `define` subcommand:

    $ bundle exec veewee <provider> define 'myubuntubox' 'ubuntu-12.10-server-amd64'

If you want to use an external repository for the definition, you can specify a git URL:

    $ bundle exec veewee <provider> define 'myubuntubox' 'git://github.com/jedi4ever/myubuntubox'

Can be `git://`, `git+ssh://` or `git+http://`.


## Modify a definition (optional)

You can tweak and customize every detail of the box by modifying and extending the (sane) default settings
that come with a template. If you want to modify these settings take a look at the [Customization](customize.md)  instructions.


## Remove a definition

If you change your mind and want to get rid of a definition simply call this subcommand:

    $ bundle exec veewee <provider> undefine 'myubuntubox'

Or you can remove the folder under `definitions`:

    $ rm -r ./definitions/myubuntubox


## Manage ISO files

The distro ISOs (also called *disk images*) provide all files needed to install the OS. This file is essential for starting the installation process.

If you already have an `.iso` file for the desired distribution on your disk, put it inside the `iso/` directory and make sure `definition.rb` is referencing the correct file.

If an expected ISO is not found in the `iso/` directory, Veewee will ask you to download the ISO file from the web. Depending on your internet connection fetching an ISO file can take a while.


## Build a new VM image

In order to build the defined box, execute this subcommand:

    $ bundle exec veewee <provider> build 'myubuntubox'

The `build` subcommand can take the following optional flags:

Flag Option                     | Description
--------------------------------|-------------
-f --force                      | overwrites if already exists
-a --auto                       | automatically downloads the ISO without asking
-n --nogui                      | builds in the background rather than opening a VM GUI and building in the GUI window
-d --debug                      | enabled debug mode output
-r --redirectconsole            | redirects console output
-i --include                    | ruby regexp of postinstall filenames to additionally include
-e --exclude                    | ruby regexp of postinstall filenames to exclude
-i --postinstall-include=[...]  | forces specified file(s) to get included in postinstall even if filename has a leading underscore
-e --postinstall-exclude=[...]  | forces specified file(s) to get excluded from postinstall even if filename has no leading underscore
--[no-]checksum                 | force to check iso file check sum
--skip-to-postinstall           | Skip the installation and go streight to postinstall. This is usefully for testing you post-install scripts.

The `build` subcommand will run the following routines behind the scenes:

* Create a machine and disk according to the `definition.rb`
  Note: `:os_type_id` is the internal name Virtualbox uses for a given distribution
* Mount the ISO file `:iso_file`
* Boot up the machine and wait for `:boot_time`
* Send the keystrokes in `:boot_cmd_sequence`
* Start up a webserver on `:kickstart_port` to wait `:kickstart_timeout` for a request for the `:kickstart_file`
  IMPORTANT: Do NOT navigate to the file in your browser or the server will stop and the installer will not be able to find your preseed
* Wait for ssh login to work with `:ssh_user` and `:ssh_password`
* `sudo` execute the `:postinstall_files`


## Validate a build

After an OS has been installed on your VM image, you can verify that the machine is configured as intended with the `validate` subcommand. Veewee provides several tests to help you with that. The tests are located under the `validation/` directory.

This subcommand executes all tests on a given machine:

    $ bundle exec veewee <provider> validate 'myubuntubox'

Validate will run some [cucumber tests](http://cukes.info/) against the box to see if it has the necessary bits and pieces (e.g. for vagrant to work).


## Export a build for distribution

The following subcommand take care of exporting:

    $ bundle exec veewee <provider> export 'myubuntubox'

The exported filetype depends on the provider. For more details on the providers, please have a look at the [Providers](providers.md) doc.


## Learn by example

Let's say you'd like to make a *Ubuntu 12.10 server (i386)* base box that's compatible with VirtualBox.

First go and find the `ubuntu-12.10-server-i386` template:

    $ bundle exec veewee vbox templates | grep -i ubuntu

Then use the `define` command to create a new definition with a custom name. The following command copies the folder `templates/ubuntu-12.10-server-i386` to `definitions/myubuntubox`:

    $ bundle exec veewee vbox define 'myubuntubox' 'ubuntu-12.10-server-i386'
    #
    # The basebox 'myubuntubox' has been successfully created from the template 'ubuntu-12.10-server-i386'
    # You can now edit the definition files stored in definitions/myubuntubox or build the box with:
    # veewee vbox build 'myubuntubox'

**IMPORTANT:** You should avoid dots and underscores in the name because the box name gets used as the hostname also. Dots in the box name currently lead to invalid hostnames which causes several negative side effects (e.g. preventing the network devices to start). Underscores might prevent the build altogether.

Confirm that all expected files are in place:

    $ ls definitions/myubuntubox
    # => definition.rb postinstall.sh preseed.cfg ...

You can now inspect and optionally [customize](customize.md) the defaults.

Next it's time to build the VM image with:

    $ bundle exec veewee vbox build 'myubuntubox'

Veewee now asks to download the distro ISO (unless `--auto` is provided) and will start creating the VM image.  This process can take some time.

After the build completes, you can run the provided test suite on your new VM:

    $ bundle exec veewee vbox validate 'myubuntubox'

Validation is highly recommended before requesting a fork pull on any modified templates.

Finally let's export the box so it can be distributed or used by Vagrant:

    $ bundle exec veewee vbox export 'myubuntubox'


## Up Next

[Customizing Definitions](customize.md) helps you fine tune each box definition to meet your exact needs.
