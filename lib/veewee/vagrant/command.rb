require 'veewee'

module Veewee

class Command < Vagrant::Command::GroupBase
  register "basebox","Commands to manage baseboxes"  
  
  desc "templates", "List the currently available basebox templates"
  def templates

#    Veewee::Session.list_templates
  end

  desc "define BOXNAME TEMPLATE", "Define a new basebox starting from a template"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
  def define(boxname, template)    
    Veewee::Session.define(boxname,template,options)
  end

  desc "undefine BOXNAME", "Removes the definition of a basebox "
  def undefine(boxname)    
      Veewee::Session.undefine(boxname)
  end

  desc "build BOXNAME", "Build the box BOXNAME"
  method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the basebox"
  method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
  method_option :definition_dir , :aliases => "-d", :desc => "definition dir"
  method_option :template_dir , :aliases => "-t", :desc => "template dir"
  method_option :iso_dir , :aliases => "-i", :desc => "iso dir"

  def build(boxname)
    session=Veewee::Session.new(options)
    session.build(boxname,options)
  end

  desc "ostypes", "List the available Operating System types"
  def ostypes
    Veewee::Session.list_ostypes
  end
  
  desc "destroy BOXNAME", "Destroys the virtualmachine that was build for a basebox"
  def destroy(boxname)
     Veewee::Session.destroy_vm(boxname)
  end
  
  desc "list", "Lists all defined baseboxes"
  def list
  Veewee::Session.list_definitions
  end
  
  desc "export [NAME]", "Exports the basebox to the vagrant box format" 
  method_options :force => :boolean  
  def export(boxname)
      if (!boxname.nil?)
        Veewee::Session.export_box(boxname)
      end
  end
  
  desc "validate [NAME]", "Validates a box against vagrant compliancy rules"
  method_option :user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
  def validate(boxname)
      if (!boxname.nil?)
        Veewee::Session.validate_box(boxname,options)
      end
  end
  
end

end
