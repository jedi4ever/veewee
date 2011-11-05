# -*- encoding: utf-8 -*-
require File.expand_path("../lib/veewee/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "veewee"
  s.version     = Veewee::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patrick Debois", "Ringo De Smet"]
  s.email       = ["patrick.debois@jedi.be", "ringo.desmet@gmail.com"]
  s.homepage    = "http://github.com/jedi4ever/veewee/"
  s.summary     = %q{Vagrant box creation}
  s.description = %q{Expand the 'vagrant box' command to support the creation of base boxes from scratch}

  s.rubyforge_project         = "veewee"

  s.add_dependency "vagrant"
  s.add_dependency "net-ssh"
  s.add_dependency "popen4"
  s.add_dependency "thor"
  s.add_dependency "highline"
  s.add_dependency "progressbar"
  s.add_dependency "cucumber"
  s.add_dependency "rspec"
  #s.add_dependency "simon", "~> 0.1.1"

  s.add_development_dependency "bundler"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

