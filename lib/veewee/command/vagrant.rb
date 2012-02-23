require 'veewee'
require 'veewee/command/vagrant/basebox'

Vagrant.commands.register(:basebox)      { Veewee::Command::Vagrant::Basebox }
