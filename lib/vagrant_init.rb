begin
  require 'vagrant'
  require 'veewee/command/vagrant'
rescue LoadError
  require 'rubygems'
  require 'veewee/command/vagrant'
  require 'veewee/command/kvm'

end
