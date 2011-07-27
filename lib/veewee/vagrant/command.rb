require 'veewee'

module Veewee

class Command < Vagrant::Command::GroupBase
  register "basebox","Commands to manage baseboxes"  

  desc "build BOXNAME", "Build the box BOXNAME"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the basebox"
  method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
  method_option :definition_dir , :aliases => "-d", :desc => "definition dir"
  method_option :template_dir , :aliases => "-t", :desc => "template dir"
  method_option :iso_dir , :aliases => "-i", :desc => "iso dir"
  def build(boxname)
    vs=Veewee::Environment.new(options)
    vd=vs.get_definition(boxname)
    vs.builder(:virtualbox).get(boxname,vd).build()
  end
  
  desc "ostypes", "List the available Operating System types"
  def ostypes
    Veewee::Environment.list_ostypes
  end
  
  desc "templates", "List the currently available basebox templates"
  def templates
    vs=Veewee::Environment.new(options)
    vs.list_templates
  end

  desc "list", "Lists all defined baseboxes"
  def list
    vs=Veewee::Environment.new(options)
    vs.list_definitions
  end
  
  desc "define BOXNAME TEMPLATE", "Define a new basebox starting from a template"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
  def define(boxname, template)    
    vs=Veewee::Environment.new(options)
    vs.define(boxname,template)
  end

  desc "undefine BOXNAME", "Removes the definition of a basebox "
  def undefine(boxname)
    vs=Veewee::Environment.new(options)
    vs.undefine(boxname)
  end
  
  desc "destroy BOXNAME", "Destroys the virtualmachine that was build for a basebox"
  def destroy(boxname)
    vs=Veewee::Environment.new(options)
    vd=vs.get_definition(boxname)
    vs.destroy(boxname,vd)
  end

  desc "export [NAME]", "Exports the basebox to the vagrant box format" 
  method_options :force => :boolean  
  def export(boxname)
    vs=Veewee::Environment.new(options)
    vs.export_box(boxname)
  end
  
  desc "validate [NAME]", "Validates a box against vagrant compliancy rules"
  method_option :user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
  def validate(boxname)
    vs=Veewee::Environment.new(options)
    vs.validate_box(boxname)
  end
  
end

end
