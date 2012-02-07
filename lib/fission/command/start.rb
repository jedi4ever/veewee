module Fission
  class Command
    class Start < Command

      def initialize(args=[])
        super
        @options.headless = false
      end

      def execute
        option_parser.parse! @args

        if @args.empty?
          Fission.ui.output self.class.help
          Fission.ui.output ""
          Fission.ui.output_and_exit "Incorrect arguments for start command", 1
        end

        vm_name = @args.first

        vm = Fission::VM.new(vm_name)

        unless vm.exists?
          Fission.ui.output_and_exit "Unable to find the VM #{vm_name} (#{Fission::VM.path(vm_name)})", 1 
        end

        if vm.running?
          Fission.ui.output ''
          Fission.ui.output_and_exit "VM '#{vm_name}' is already running", 0
        end

        Fission.ui.output "Starting '#{vm_name}'"
        start_args = {}

        if @options.headless

          if Fission::Fusion.running?
            Fission.ui.output 'It looks like the Fusion GUI is currently running'
            Fission.ui.output 'A VM cannot be started in headless mode when the Fusion GUI is running'
            Fission.ui.output_and_exit "Exit the Fusion GUI and try again", 1
          else
            start_args[:headless] = true
          end
        end

        task = vm.start(start_args)

        if task.successful?
          Fission.ui.output "VM '#{vm_name}' started"
        else
          Fission.ui.output_and_exit "There was a problem starting the VM.  The error was:\n#{task.output}", task.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nstart usage: fission start vm [options]"

          opts.on '--headless', 'Start the VM in headless mode (i.e. no Fusion GUI console)' do
            @options.headless = true
          end
        end

        optparse
      end

    end
  end
end
