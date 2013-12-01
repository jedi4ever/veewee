# Vagrant

If you don't find what you're looking for here, please see the official [Vagrant docs](http://docs.vagrantup.com/v2/) for more information.


## Typical workflow to build a Vagrant VM image

A simple workflow to build a VirtualBox VM for Vagrant would be:

    $ bundle exec veewee vbox templates | grep -i ubuntu
    $ bundle exec veewee vbox define 'myubuntubox' 'ubuntu-12.10-server-amd64'
    $ bundle exec veewee vbox build 'myubuntubox'

For additional box building instructions, see the [Veewee Basics](basics.md) and [Definition Customization](customize.md) docs.

To build a VM for another provider, such as VMware Fusion, you'd use "fusion" instead of "vbox" in the above.

## Export the VM image to a .box file

In order to use the box in Vagrant, we need to export the VM as a [base box](http://docs.vagrantup.com/v2/boxes.html) (e.g. export to the .box filetype):

    $ bundle exec veewee vbox export 'myubuntubox'

This is actually calling `vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'`.

The machine gets shut down, exported and will be packed in a `myubuntubox.box` file inside the current directory.


## Add the exported .box to Vagrant

To import it into Vagrant's box repository simply type:

    $ vagrant box add 'myubuntubox' 'myubuntubox.box'

The parameter 'myubuntubox' sets the name that Vagrant will use to reference the box (i.e. in the `Vagrantfile`).


## Use the added box in Vagrant

To use your newly generated box in a fresh project execute these commands:

    $ vagrant init 'myubuntubox'

If you already have a project running with Vagrant, open the `Vagrantfile` and change the value of `config.vm.box` to the new box name:

    Vagrant.configure("2") do |config|
      config.vm.box = "myubuntubox"
    end

See the [Vagrantfile machine settings](http://docs.vagrantup.com/v2/vagrantfile/machine_settings.html) for more details on setting up your `Vagrantfile` configuration.

Now start the new environment with `vagrant up` and log in with `vagrant ssh` to enjoy your new environment.
