require 'thor'
require 'thor/actions'

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
      # @param [String] usage
      # @param [String] description
      # @param [Hash] opts
      def self.register(usage, description, opts=nil)
        @_name = Base.extract_name_from_usage(usage)
        CLI.register(self, @_name, usage, description, opts)
      end

      def initialize(*args)
        super
        initialize_environment(*args)
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
