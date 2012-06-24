module Fission
  class Command
    class SnapshotRevert < Command

      def initialize(args=[])
        super
      end

      def execute
        unless @args.count == 2
          Fission.ui.output self.class.help
          Fission.ui.output ''
          Fission.ui.output_and_exit 'Incorrect arguments for snapshot revert command', 1
        end

        vm_name, snap_name = @args.take 2
        vm = Fission::VM.new vm_name

        unless vm.exists? vm_name
          Fission.ui.output_and_exit "Unable to find the VM #{vm_name} (#{Fission::VM.path(vm_name)})", 1 
        end

        if Fission::Fusion.running?
          Fission.ui.output 'It looks like the Fusion GUI is currently running'
          Fission.ui.output_and_exit 'Please exit the Fusion GUI and try again', 1
        end

        snaps = vm.snapshots

        unless snaps.include? snap_name
          Fission.ui.output_and_exit "Unable to find the snapshot '#{snap_name}'", 1
        end

        Fission.ui.output "Reverting to snapshot '#{snap_name}'"
        task = vm.revert_to_snapshot snap_name

        if task.successful?
          Fission.ui.output "Reverted to snapshot '#{snap_name}'"
        else
          Fission.ui.output_and_exit "There was an error reverting to the snapshot.  The error was:\n#{task.output}", task.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nsnapshot revert: fission snapshot revert my_vm snapshot_1"
        end

        optparse
      end

    end
  end
end
