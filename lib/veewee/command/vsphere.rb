module Veewee
  module Command
    class Vsphere< Veewee::Command::GroupBase

      register "vsphere", "Subcommand for Vmware vsphere"
      desc "build [BOX_NAME]", "Build box"
      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :datastore,:type => :string , :default => nil, :aliases => "-s", :desc => "VSphere Datastore"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).build(options)
      end

      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :datastore,:type => :string , :default => nil, :aliases => "-s", :desc => "VSphere Datastore"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "create [BOXNAME]", "Creates the virtualmachine without building"
      def create(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).create(options)
      end

      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was built"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).destroy(options)
      end

      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown" 
      desc "halt [BOXNAME]", "Activates a shutdown the virtualmachine"
      def halt(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).halt(options)
      end

      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOXNAME]", "Starts a Box"
      def up(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).up(options)
      end

      desc "scp [BOXNAME] [LOCAL FILE] [REMOTE FILE]", "SCP to box"
      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def scp(box_name,local_file,remote_file)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).scp(local_file,remote_file)
      end

      desc "ssh [BOXNAME] [COMMAND]", "SSH to box"
      method_option :vsphere_host,:type => :string , :default => nil, :aliases => "-h", :desc => "VSphere Host"
      method_option :vsphere_user,:type => :string , :default => nil, :aliases => "-u", :desc => "VSphere User"
      method_option :vsphere_password,:type => :string , :default => nil, :aliases => "-p", :desc => "VSphere Password"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ssh(box_name,command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).issh(command)
      end

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def define(definition_name, template_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.define(definition_name,template_name,options)
        env.ui.info "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui.info "veewee vsphere build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}" , :prefix => false
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.definitions.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} succesfully removed",:prefix => false
        rescue Error => ex
          env.ui.error "#{ex}" , :prefix => false
          exit -1
        end
      end
=begin
      desc "validate [NAME]", "Validates a box against vsphere compliancy rules"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :tags, :type => :array , :default => %w{vsphere puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).validate_vsphere(options)
      end

      desc "ostypes", "List the available Operating System types"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.ostypes.each do |name|
           env.ui.info "- #{name}"
        end
      end

      desc "export [NAME]", "Exports the basebox to the ova format"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite existing file"
      def export(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vsphere"].get_box(box_name).export_ova(options)
      end

=end

      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def templates
        env.ui.info "The following templates are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.templates.each do |name,template|
          env.ui.info "veewee vsphere define '<box_name>' '#{name}'",:prefix => false
        end
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def list
        env.ui.info "The following local definitions are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.each do |name,definition|
          env.ui.info "- #{name}"
        end
      end

    end

  end
end
