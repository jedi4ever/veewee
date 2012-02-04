module Veewee
  module Command
    autoload :Base,      'veewee/command/base'
    autoload :GroupBase, 'veewee/command/group_base'
    autoload :Helpers,   'veewee/command/helpers'
    autoload :NamedBase, 'veewee/command/named_base'
  end
end

# The built-in commands must always be loaded
require 'veewee/command/version'
require 'veewee/command/kvm'
require 'veewee/command/virtualbox'
require 'veewee/command/vmfusion'