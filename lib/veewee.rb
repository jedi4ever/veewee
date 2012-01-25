require 'vagrant'
require 'veewee/command'

Vagrant.commands.register(:basebox)      { Veewee::Command::Basebox }
