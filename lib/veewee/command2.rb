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

#Initialize
Veewee::Session.setenv({:veewee_dir => veewee_dir, :definition_dir => definition_dir,
   :template_dir => template_dir, :iso_dir => iso_dir, :box_dir => box_dir, :tmp_dir => tmp_dir})

puts "we get here"

class Command22 < Vagrant::Command::GroupBase
  register "basebox","Commands to manage baseboxes"  

  desc "templates", "List the currently available box templates"
  def templates
    Veewee::Session.list_templates
  end

  desc "define BOXNAME TEMPLATE", "Define a new box starting from a template"
  def define(boxname, template)
    puts "define a new box #{boxname}, starting from template #{template}"
    Veewee::Session.define(boxname,template)
  end

  desc "build BOXNAME", "Build the box BOXNAME"
  def build(boxname)
    puts "Building box #{boxname}"
    Veewee::Session.build(boxname)
  end

  desc "ostypes", "List the available Operating System types"
  def ostypes
    puts "Operating System types:"
    Veewee::Session.list_ostypes
  end

  desc "clean", "Clean all unfinished builds"
  def clean
    puts "Cleaning all unfinished builds"
  end
  
end


class SayHelloCommand < Vagrant::Command::Base
  register "hello", "Says hello then goodbye"

  def hello
    puts "HELLO!"
  end

  def goodbye
    puts "GOODBYE!"
  end
end
