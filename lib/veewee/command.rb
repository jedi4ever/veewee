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

module Veewee
class Command < Vagrant::Command::GroupBase
  register "basebox","Commands to manage baseboxes"  

  desc "templates", "List the currently available box templates"
  def templates
    Veewee::Session.list_templates
  end

  desc "define BOXNAME TEMPLATE", "Define a new box starting from a template"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
  def define(boxname, template)    
    Veewee::Session.define(boxname,template,options)
  end

  desc "build BOXNAME", "Build the box BOXNAME"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the basebox"
  def build(boxname)
    Veewee::Session.build(boxname,options)
  end

  desc "ostypes", "List the available Operating System types"
  def ostypes
    Veewee::Session.list_ostypes
  end
  
  desc "destroy BOXNAME", "Destroy the virtualmachine of a basebox"
  def destroy(boxname)
    puts Veewee::Session.destroy_vm(boxname)
  end
  
  desc "list", "Lists all defined boxes"
  def list
  Veewee::Session.list_definitions
  end
  
  desc "export [NAME]", "export the box" 
  method_options :force => :boolean  
  def export(boxname)
      if (!boxname.nil?)
        Veewee::Session.export_box(boxname)
      end
  end
  
end

end