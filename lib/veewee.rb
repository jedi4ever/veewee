require 'json'
require 'i18n'

module Veewee
  # The source root is the path to the root directory of
  # the Veewee gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end
end

# # Default I18n to load the en locale
I18n.load_path << File.expand_path("templates/locales/en.yml", Veewee.source_root)

# Load the things which must be loaded before anything else
require 'veewee/cli'
require 'veewee/ui'
require 'veewee/command'
require 'veewee/error'
require 'veewee/environment'
require 'veewee/version'