module Fission
  class Command
    class Stop < Command

      def initialize(args=[])
        super
      end

      def execute
        unless @args.count == 1
          Fission.ui.output self.class.help
          Fission.ui.output ""
          Fission.ui.output_and_exit "Incorrect arguments for stop command", 1
        end

        vm_name = @args.first
        vm = Fission::VM.new vm_name

        unless vm.exists? 
          Fission.ui.output_and_exit "VM #{vm_name} does not exist at (#{vm.path})", 1
        end


        unless vm.running?
          Fission.ui.output ''
          Fission.ui.output_and_exit "VM '#{vm_name}' is not running", 0
        end

        Fission.ui.output "Stopping '#{vm_name}'"
        task  = vm.stop

        if task.successful?
          Fission.ui.output "VM '#{vm_name}' stopped"
        else
          Fission.ui.output_and_exit "There was an error stopping the VM.  The error was:\n#{response.output}", response.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nstop usage: fission stop vm"
        end

        optparse
      end

    end
  end
end
