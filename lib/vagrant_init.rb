begin
  require 'vagrant'
  require 'veewee/vagrant/command'
rescue LoadError
  require 'rubygems'
  require 'veewee/vagrant/command'
  require 'veewee/command/kvm'

end
