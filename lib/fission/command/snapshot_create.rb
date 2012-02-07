module Fission
  class Command
    class SnapshotCreate < Command

      def initialize(args=[])
        super
      end

      def execute
        unless @args.count == 2
          Fission.ui.output self.class.help
          Fission.ui.output ""
          Fission.ui.output_and_exit "Incorrect arguments for snapshot create command", 1
        end

        vm_name, snap_name = @args.take 2

        vm = Fission::VM.new vm_name
        unless vm.exists?
          Fission.ui.output_and_exit "Unable to find the VM #{vm_name} (#{Fission::VM.path(vm_name)})", 1 
        end

        unless vm.running?
          Fission.ui.output "VM '#{vm_name}' is not running"
          Fission.ui.output_and_exit 'A snapshot cannot be created unless the VM is running', 1
        end

        if vm.snapshots.include? snap_name
          Fission.ui.output_and_exit "VM '#{vm_name}' already has a snapshot named '#{snap_name}'", 1
        end

        Fission.ui.output "Creating snapshot"
        task = vm.create_snapshot(snap_name)

        if task.successful?
          Fission.ui.output "Snapshot '#{snap_name}' created"
        else
          Fission.ui.output_and_exit "There was an error creating the snapshot.  The error was:\n#{task.output}", task.code
        end
      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nsnapshot create: fission snapshot create my_vm snapshot_1"
        end

        optparse
      end

    end
  end
end
