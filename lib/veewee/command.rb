require 'veewee/session'

#Setup some base variables to use
veewee_dir= File.expand_path(File.join(File.dirname(__FILE__),"..",".."))
definition_dir= File.expand_path(File.join(".", "definitions"))
lib_dir= File.expand_path(File.join(veewee_dir, "lib"))
box_dir= File.expand_path(File.join(veewee_dir, "boxes"))
template_dir=File.expand_path(File.join(veewee_dir, "templates"))

#vbox_dir=File.expand_path(File.join(veewee_dir, "tmp"))
tmp_dir=File.expand_path(File.join(veewee_dir, "tmp"))

iso_dir=File.expand_path(File.join(veewee_dir, "iso"))

#needs to be moved to the config files to be allowed override
#ENV['VBOX_USER_HOME']=vbox_dir

#Load Veewee::Session libraries
Dir.glob(File.join(lib_dir, '**','*.rb')).each {|f|
  require f  }

#Initialize
Veewee::Session.setenv({:veewee_dir => veewee_dir, :definition_dir => definition_dir,
   :template_dir => template_dir, :iso_dir => iso_dir, :box_dir => box_dir, :tmp_dir => tmp_dir})


module Vagrant
  module Command
    class BoxCommand < Vagrant::Command::GroupBase
      # Do not register anymore, as this registration is already done in Vagrant core
      # Since Ruby classes are 'open', we are just adding subcommands to the 'box' command

      desc "templates", "List the currently available box templates"
      def templates
	    Veewee::Session.list_templates
      end

      desc "init BOXNAME TEMPLATE", "Define a new box starting from a template"
      def init(boxname, template)
	puts "Init a new box #{boxname}, starting from template #{template}"
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
  end
end
