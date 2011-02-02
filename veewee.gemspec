# -*- encoding: utf-8 -*-
require File.expand_path("../lib/veewee/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "veewee"
  s.version     = Veewee::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patrick Debois", "Ringo De Smet"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://rubygems.org/gems/vagrant-rake"
  s.summary     = "A plugin to create boxes"
  s.description = "A plugin to create boxes"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "veewee"

  s.add_dependency "vagrant", "~> 0.7.0"
  s.add_dependency "net-ssh", "~> 2.1.0"
  s.add_dependency "popen4", "~> 0.1.2"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

