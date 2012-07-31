module Fission
  class Command
    class Clone < Command

      def initialize(args=[])
        super
        @options.start = false
      end

      def execute
        option_parser.parse! @args

        unless @args.count > 1
          Fission.ui.output self.class.help
          Fission.ui.output ""
          Fission.ui.output_and_exit "Incorrect arguments for clone command", 1
        end

        source_vm_name = @args.first
        target_vm_name = @args[1]
        source_vm=Fission::VM.new(source_vm_name)
        target_vm=Fission::VM.new(target_vm_name)

        unless source_vm.exists?
            Fission.ui.output_and_exit "Unable to find the source vm #{source_vm_name} (#{source_vm.path})", 1
        end

        if target_vm.exists?
            Fission::ui.output_and_exit "The target vm #{target_vm_name} already exists", 1
        end

        clone_task = Fission::VM.clone source_vm_name, target_vm_name

        if clone_task.successful?
          Fission.ui.output ''
          Fission.ui.output 'Clone complete!'

          if @options.start
            Fission.ui.output "Starting '#{target_vm_name}'"

            start_task = target_vm.start

            if start_task.successful?
              Fission.ui.output "VM '#{target_vm_name}' started"
            else
              Fission.ui.output_and_exit "There was an error starting the VM.  The error was:\n#{start_task.output}", start_task.code
            end
          end
        else
          Fission.ui.output_and_exit "There was an error cloning the VM.  The error was:\n#{clone_task.output}", clone_task.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nclone usage: fission clone source_vm target_vm [options]"

          opts.on '--start', 'Start the VM after cloning' do
            @options.start = true
          end
        end

        optparse
      end

    end
  end
end
