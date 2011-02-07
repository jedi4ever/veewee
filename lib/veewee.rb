require 'vagrant'
#require 'veewee/config'
require 'veewee/command'
#require 'veewee/middleware'


#basebox = Vagrant::Action::Builder.new do
  #use BaseBoxMiddleware
#end

#Vagrant::Action.register :basebox, basebox

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

