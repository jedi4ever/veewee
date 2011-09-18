module Veewee
  module Vagrant
  module UI
    class VagrantPlugin

      def self.list_ostypes(options={})
        puts "The following are possible os_types you can use in your definition.rb files"
        ostypes=Veewee::Environment.new(options).get_builder(:virtualbox,options).list_ostypes(options).collect { |os|
          puts "#{os.id}: #{os.description}"
        }
      end

      def self.list_templates(options={})
        puts "The following templates are available:"
        Veewee::Environment.new(options).get_templates.each do |name|
          puts "vagrant basebox define '<box_name>' '#{name}'"
        end
      end

      def self.list_definitions(options={})
        puts "The following local definitions are available:"
        Veewee::Environment.new(options).get_definitions.each do |name|
          puts "- #{name}"
        end
      end


      def self.define(definition_name, template_name,define_options={})

        begin
          Veewee::Environment.new(define_options).define(definition_name,template_name,define_options)
        rescue TemplateError
          puts "This template can not be found, use vagrant basebox templates to list all templates"
          exit -1
        rescue DefinitionError
          puts "The definition for #{definition_name} already exists. Use --force to overwrite"
          exit -1
        end

        puts "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        puts "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        puts "vagrant basebox build '#{definition_name}'"
      end

      def self.undefine(definition_name,undefine_options={})
        puts "Removing definition #{definition_name}"
        begin
          Veewee::Environment.new(undefine_options).undefine(definition_name,undefine_options)
          puts "Definition #{definition_name} succesfully removed"
        rescue DefinitionError => ex
          puts "#{ex}"
          exit -1
        end
      end

      def self.build(box_name,options={})
        box=Veewee::Environment.new(options).get_builder(:virtualbox,options).get_box(box_name,box_name,options)
        box.build(options)
      end

      def self.validate(box_name,options={})
        box=Veewee::Environment.new(options).get_builder(:virtualbox,options).get_box(box_name,box_name,options)
        box.validate_vagrant(options)
      end

      def self.export(box_name,options={})
        box=Veewee::Environment.new(options).get_builder(:virtualbox,options).get_box(box_name,box_name,options)
        box.export_vagrant(options)
      end

      def self.destroy(box_name,options={})
        box=Veewee::Environment.new(options).get_builder(:virtualbox,options).get_box(box_name,box_name,options)
        box.destroy(options)
      end

    end
  end
end
end