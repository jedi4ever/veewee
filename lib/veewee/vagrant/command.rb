require 'veewee'
require 'veewee/ui/vagrant_plugin'

module Veewee

  class Command < Vagrant::Command::GroupBase
    register "basebox","Commands to manage baseboxes"  

    desc "ostypes", "List the available Operating System types"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    def ostypes
      Veewee::UI::VagrantPlugin.list_ostypes(options)
    end

    desc "templates", "List the currently available basebox templates"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :template_dir , :aliases => "-t", :desc => "directory where templates are found"
    def templates
      Veewee::UI::VagrantPlugin.list_templates(options)
    end

    desc "list", "Lists all defined baseboxes"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    def list
      Veewee::UI::VagrantPlugin.list_definitions(options)
    end

    desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    method_option :template_dir , :aliases => "-t", :desc => "directory where templates are found"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    def define(box_name, template)
      Veewee::UI::VagrantPlugin.define(box_name,template,options)
    end

    desc "undefine [BOXNAME]", "Removes the definition of a basebox "
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    def undefine(box_name)
      Veewee::UI::VagrantPlugin.undefine(box_name,options)
    end

    desc "build [BOXNAME]", "Build the box BOXNAME"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :ssh_user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
    method_option :ssh_password, :default => "vagrant", :desc => "password to login with"
    method_option :ssh_key, :aliases => "-k", :desc => "ssh key to login with"
    method_option :ssh_port, :aliases => "-p", :desc => "ssh port to login to"    
    method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the basebox"
    method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    method_option :temp_dir , :desc => "directory where tempory files are created"
    method_option :template_dir , :aliases => "-t", :desc => "directory where templates are found"
    method_option :iso_dir , :aliases => "-i", :desc => "directory where to look/store iso images"
    method_option :box_name , :desc => "name to use for the box"
    def build(box_name)
      Veewee::UI::VagrantPlugin.build(box_name,options)
    end

    desc "validate [NAME]", "Validates a box against vagrant compliancy rules"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :ssh_user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
    method_option :ssh_password, :default => "vagrant", :desc => "password to login with"
    method_option :ssh_key, :aliases => "-k", :desc => "ssh key to login with"
    method_option :ssh_port, :aliases => "-p", :desc => "ssh port to login to"
    method_option :box_name ,  :aliases => "-n", :desc => "name to use for the box"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    def validate(box_name)
      Veewee::UI::VagrantPlugin.validate(box_name,options)
    end

    desc "export [NAME]", "Exports the basebox to the vagrant box format" 
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :ssh_user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
    method_option :ssh_password, :default => "vagrant", :desc => "password to login with"
    method_option :ssh_key, :aliases => "-k", :desc => "ssh key to login with"
    method_option :ssh_port, :aliases => "-p", :desc => "ssh port to login to"    
    method_option :force => :boolean,  :default => false, :aliases => "-f", :desc => "force overwrite box file"
    method_option :box_name , :aliases => "-n", :desc => "name to use for the box"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    method_option :vagrant_box_name, :desc => "name of vagrant box"
    def export(box_name)
      Veewee::UI::VagrantPlugin.export(box_name,options)
    end 

    desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build for a basebox"
    method_option :log_level, :default => 'info', :desc => "info,warning,debug"
    method_option :log_file, :desc => "file to output log"
    method_option :ssh_user,:default => "vagrant", :aliases => "-u", :desc => "user to login with"
    method_option :ssh_password, :default => "vagrant", :desc => "password to login with"
    method_option :ssh_key, :aliases => "-k", :desc => "ssh key to login with"
    method_option :ssh_port, :aliases => "-p", :desc => "ssh port to login to"
    method_option :box_name , :aliases => "-n", :desc => "name to use for the box"
    method_option :definition_dir , :aliases => "-d", :desc => "directory where definitions are found"
    def destroy(box_name)
      Veewee::UI::VagrantPlugin.destroy(box_name,options)
    end

  end

end