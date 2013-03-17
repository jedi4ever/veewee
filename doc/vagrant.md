# Vagrant

A typical workflow with Vagrant would be:

    $ vagrant basebox define 'mybuntubox' 'ubuntu-12.10-server-amd64'
    $ vagrant basebox build 'mybuntubox'
    $ vagrant basebox export 'mybuntubox'

Now you can import the generated '.box' file to the vagrant box repository:

    $ vagrant box add 'mybuntubox' 'mybuntubox.box'


## Export the vm to a .box file

In order to use the box in Vagrant we need to export the VM as a [Basebox](http://vagrantup.com/v1/docs/base_boxes.html):

    $ vagrant basebox export 'myubuntubox'

This is actually calling `vagrant package --base 'myubuntubox' --output 'boxes/myubuntubox.box'`.

The machine gets shut down, exported and will be packed in a `myubuntubox.box` file inside the current directory.


## Add the new box as one of your Vagrant boxes

To import it into Vagrant's box repository simply type:

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
