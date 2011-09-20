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