module Fission
  class Command
    class SnapshotList < Command

      def initialize(args=[])
        super
      end

      def execute
        unless @args.count == 1
          Fission.ui.output self.class.help
          Fission.ui.output ""
          Fission.ui.output_and_exit "Incorrect arguments for snapshot list command", 1
        end

        vm_name = @args.first

        vm = Fission::VM.new vm_name

        unless vm.exists? 
          Fission.ui.output_and_exit "Unable to find the VM #{vm_name} (#{vm.path})", 1 
        end

        snaps=vm.snapshots
        unless snaps.empty?
            Fission.ui.output snaps.join("\n")
        else
          Fission.ui.output "No snapshots found for VM '#{vm_name}'"
        end

        # TODO
        Fission.ui.output_and_exit "There was an error listing the snapshots.  The error was:\n#{task.output}", task.code
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nsnapshot list: fission snapshot list my_vm"
        end

        optparse
      end

    end
  end
end
