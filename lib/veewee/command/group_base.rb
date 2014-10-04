require 'thor'
require 'thor/actions'
require 'veewee/environment'

module Veewee
  module Command
    # A {GroupBase} is the superclass which should be used if you're
    # creating a CLI command which has subcommands such as `veewee box`,
    # which has subcommands such as `add`, `remove`, `list`. If you're
    # creating a simple command which has no subcommands, such as `veewee up`,
    # then use {Base} instead.
    #
    # Unlike {Base}, where all public methods are executed, in a {GroupBase},
    # each public method defines a separate task which can be invoked. The best
    # way to get examples of how to create a {GroupBase} command is to look
    # at the built-in commands, such as {BoxCommand}.
    #
    # # Defining a New Command
    #
    # To define a new command with subcommands, create a new class which inherits
    # from this class, then call {register} to register the command. That's it! When
    # the command is invoked, the method matching the subcommand is invoked. An
    # example is shown below:
    #
    #     class SayCommand < Veewee::Command::GroupBase
    #       register "say", "Say hello or goodbye"
    #
    #       desc "hello", "say hello"
    #       def hello
    #         env.ui.info "Hello"
    #       end
    #
    #       desc "goodbye", "say goodbye"
    #       def goodbye
    #         env.ui.info "Goodbye"
    #       end
    #     end
    #
    # In this case, the above class is invokable via `veewee say hello` or
    # `veewee say goodbye`. To give it a try yourself, just copy and paste
    # the above into a Veeweefile somewhere, and run `veewee` from within
    # that directory. You should see the new command!
    #
    # Also notice that in the above, each task follows a `desc` call. This
    # call is used to provide usage and description for each task, and is
    # required.
    #
    # ## Defining Command-line Options
    #
    # ### Arguments
    #
    # To define arguments to your commands, such as `veewee say hello mitchell`,
    # then you simply define them as arguments to the method implementing the
    # task. An example is shown below (only the method, to keep things brief):
    #
    #     def hello(name)
    #       env.ui.info "Hello, #{name}"
    #     end
    #
    # Then, if `veewee say hello mitchell` was called, then the output would
    # be "Hello, mitchell"
    #
    # ### Switches or Other Options
    #
    # TODO
    class GroupBase < Thor
      include Thor::Actions
      include Helpers

      class_option :debug,:type => :boolean , :default => false, :desc => "enable debugging"

      class_option :cwd, :aliases => ['-w', '--workdir'],  :type => :string,
                   :default => Veewee::Environment.workdir,
                   :desc => "Change the working directory. (The folder containing the definitions folder)."

      attr_reader :env

      # Register the command with the main Veewee CLI under the given
      # usage. The usage will be used for accessing it from the CLI,
      # so if you give it a usage of `lamp [subcommand]`, then the command
      # to invoke this will be `veewee lamp` (with a subcommand).
      #
      # The description is used when a listing of the commands is given
      # and is meant to be a brief (one sentence) description of what this
      # command does.
      #
      # Some additional options may be passed in as the last parameter:
      #
      # * `:alias` - If given as an array or string, these will be aliases
      #  for the same command. For example, `veewee version` is also
      #  `veewee --version` and `veewee -v`
      #
      def self.register(options = {})
        # self refers to the class object of the provider subclass
        self.send(:class_variable_set, :@@command,     options[:command]    )
        self.send(:class_variable_set, :@@description, options[:description])
        self.send(:class_variable_set, :@@provider,    options[:provider]   )
        CLI.register(self, options[:command], options[:command], options[:description], options[:opts])
      end

      def initialize(*args)
        super
        # make provider class variables easily available to global task methods
        @command = self.class.class_variable_get(:@@command)
        @description = self.class.class_variable_get(:@@description)
        @provider = self.class.class_variable_get(:@@provider)
        initialize_environment(*args)
        @env.current_provider = @provider
      end

      desc "templates", "List the currently available templates"
      method_option :box_name, :default => '<box_name>', :aliases => ['-b'], :desc => "Name of the box you want create."
      def templates
        env.ui.info "The following templates are available:",:prefix => false
        env.templates.each do |name,template|
          env.ui.info "veewee #{@command} define '#{options[:box_name]}' '#{name}' --workdir=#{options[:cwd]}",:prefix => false
        end
      end

      desc "list", "Lists all defined boxes"
      def list
        venv=env
        env.ui.info "The following definitions are available in #{venv.cwd}: ",:prefix => false
        venv.definitions.each do |name,definition|
          env.ui.info "- #{name}",:prefix => false
        end
      end

      desc "define [BOX_NAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      def define(definition_name, template_name)
        begin
          env.definitions.define(definition_name,template_name,options)
          env.ui.info "The basebox '#{definition_name}' has been successfully created from the template '#{template_name}'"
          env.ui.info "You can now edit the definition files stored in #{options[:cwd]}/definitions/#{definition_name} or build the box with:"
          env.ui.info "veewee #{@command} build '#{definition_name}' --workdir=#{options[:cwd]}"
        rescue Error => ex
          env.ui.error("#{ex}",:prefix => false)
          exit -1
        end
      end

      desc "winrm [BOX_NAME] [COMMAND]", "Execute command via winrm"
      def winrm(box_name, command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).winrm(command,{:exitcode => "*"})
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "destroy [BOX_NAME]", "Destroys the virtualmachine that was built"
      def destroy(box_name)
        env.get_box(box_name).destroy(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown"
      desc "halt [BOX_NAME]", "Activates a shutdown the virtualmachine"
      def halt(box_name)
        env.get_box(box_name).halt(options)
      end

      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOX_NAME]", "Starts a Box"
      def up(box_name)
        env.get_box(box_name).up(options)
      end

      desc "ssh [BOX_NAME] [COMMAND]", "SSH to box"
      def ssh(box_name, command=nil)
        env.get_box(box_name).issh(command)
      end

      desc "copy [BOX_NAME] [SRC] [DST]", "Copy a file to the VM"
      def copy(box_name, src, dst)
        env.get_box(box_name).copy_to_box(src,dst)
      end

      desc "undefine [BOX_NAME]", "Removes the definition of a basebox "
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}" , :prefix => false
        begin
          env.definitions.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} successfully removed",:prefix => false
        rescue Error => ex
          env.ui.error "#{ex}" , :prefix => false
          exit -1
        end
      end

      desc "ostypes", "List the available Operating System types"
      def ostypes
        env.ostypes.each do |name|
          env.ui.info "- #{name}"
        end
      end

      desc "sendkeys [BOX_NAME] [SEQUENCE]", "Sends the key sequence (comma separated) to the box. E.g for testing the :boot_cmd_sequence"
      def sendkeys(box_name, sequence)
        env.get_box(box_name).console_type(sequence.split(","))
      end

protected

      # Override the basename to include the subcommand name.
      def self.basename
        "#{super}"
        #"#{super} #{@_name}"
      end
    end
  end
end
