# -*- encoding: utf-8 -*-
require File.expand_path("../lib/veewee/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "veewee"
  s.version     = Veewee::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ["Patrick Debois"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://github.com/jedi4ever/veewee/"
  s.summary     = %q{Vagrant box creation}
  s.description = %q{Expand the 'vagrant box' command to support the creation of base boxes from scratch}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "veewee"


  # Currently locked to 2.2.0
  # if specifying to >= 2.2.0 it would use 2.3 and bundler would go in a resolver loop
  # DEBUG_RESOLVER=1 bundle install
  s.add_dependency "net-ssh", ">= 2.2.0"

  s.add_dependency "mime-types", "~> 1.16"
  s.add_dependency "popen4", "~> 0.1.2"
  s.add_dependency "thor", "~> 0.15"
  s.add_dependency "highline"
  s.add_dependency "json"
  #s.add_dependency "json", ">= 1.5.1", "< 1.8.0"
  s.add_dependency "progressbar"
  s.add_dependency "i18n"
  #s.add_dependency "cucumber", ">=1.0.0"
  s.add_dependency "ansi", "~> 1.3.0"
  s.add_dependency "ruby-vnc", "~> 1.0.0"
  s.add_dependency "fog", "~> 1.8"
  s.add_dependency "childprocess"
  s.add_dependency "grit"
  s.add_dependency "fission", "0.5.0"
  s.add_dependency "to_slug"
  s.add_dependency "os", "~> 0.9.6"
  s.add_dependency "gem-content", "~>1.0"

  s.required_ruby_version = '>= 1.9.3'

  # Modified dependency version, as libxml-ruby dependency has been removed in version 2.1.1
  # See : https://github.com/ckruse/CFPropertyList/issues/14
  # See : https://github.com/jedi4ever/veewee/issues/6
  #s.add_dependency "CFPropertyList", ">= 2.1.1"
#  s.add_dependency "libvirt"
  s.add_development_dependency "rspec", "~> 2.5"

  s.add_development_dependency "bundler", ">= 1.0.0"
  #s.add_development_dependency('ruby-libvirt','~>0.4.0')

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'

  s.metadata = {
    "veewee-templates" => "templates"
  }
end
