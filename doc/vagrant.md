# Define a new box

Veewee uses `definitions` to create new boxes. Every definition is based on a `template`.

A `template` is represented by a sub-directory in the folder `templates`. Here you find all the templates you can use.

The folder name has a schema to help you choosing the right template:

    ubuntu-12.10-server-i386[-netboot]
                             ^ ----- install flavor (optional)
                        ^ ----- architecture
           ^ ----- version
    ^ ----- OS name


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

If you want to modify these settings take a look at [customization instructions](doc/customize.md).


## Getting the CD-ROM file in place

The CD-ROM file (.iso) file is needed to start the installation process.

Depending on your internet connection fetching a ISO file can take several minutes.

If you already have an .iso file for the desired distribution you can put the isofile inside the `./iso` directory.

Create this directory if it does not exist. Otherwise Veewee will ask you to download the ISO file fro the web.


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


## Export the vm to a .box file

In order to use the box in Vagrant we need to export the VM as a [Basebox](http://vagrantup.com/v1/docs/base_boxes.html):

    $ vagrant basebox export 'myubuntubox'

This is actually calling `vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'`.

The machine gets shut down, exported and will be packed in a `myubuntubox.box` file inside the current directory.


## Add the new box as one of your Vagrant boxes

These steps are specific to vagrant. To import it into Vagrant's box repository simply type:

    $ vagrant box add 'myubuntubox' 'myubuntubox.box'

The parameter 'myubuntubox' sets the name of the box that is used by Vagrant to reference the box e.g. in the `Vagrantfile`.

See http://docs.vagrantup.com/v1/docs/boxes.html for more details.


## Use it in vagrant

To use your newly generated box in a fresh project execute these commands:

    $ vagrant init 'myubuntubox'

If you already have a project running with Vagrant, open the `Vagrantfile` and change the value of `config.vm.box`
to the new boxname:

    Vagrant::Config.run do |config|
      config.vm.box = "myubuntubox"

Now start the new environment with `vagrant up` and log in with `vagrant ssh` to enjoy the joys of your new environment.