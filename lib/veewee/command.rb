require 'veewee/session'

#Load Veewee::Session libraries
lib_dir= File.expand_path(File.join(File.dirname(__FILE__),"..","..", "lib"))
Dir.glob(File.join(lib_dir, '**','*.rb')).each {|f| require f  }

#Setup some base variables to use
template_dir=File.expand_path(File.join(lib_dir,"..", "templates"))

veewee_dir="."
definition_dir= File.expand_path(File.join(veewee_dir, "definitions"))
tmp_dir=File.expand_path(File.join(veewee_dir, "tmp"))
iso_dir=File.expand_path(File.join(veewee_dir, "iso"))
box_dir=File.expand_path(File.join(veewee_dir, "boxes"))
validation_dir=File.expand_path(File.join(lib_dir, "..","validation"))

#Initialize
Veewee::Session.setenv({:veewee_dir => veewee_dir, :definition_dir => definition_dir,
   :template_dir => template_dir, :iso_dir => iso_dir, :box_dir => box_dir, :tmp_dir => tmp_dir, :validation_dir => validation_dir})

module Veewee
  module Command
  end
end
