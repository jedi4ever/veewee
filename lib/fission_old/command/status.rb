module Fission
  class Command
    class Status < Command

      def initialize(args=[])
        super
      end

      def execute

        all_vms=Fission::VM.all
        vm_with_longest_name = all_vms.max { |a,b| a.name.length <=> b.name.length }
        max_name_length=vm_with_longest_name.name.length
        all_vms.each do |vm|
          status = vm.state
          Fission.ui.output_printf "%-#{max_name_length}s   %s\n", vm.name, "["+status+"]"
        end

      end

      def option_parser
        optparse = OptionParser.new do |opts|
          opts.banner = "\nstatus usage: fission status"
        end

        optparse
      end

    end
  end
end
