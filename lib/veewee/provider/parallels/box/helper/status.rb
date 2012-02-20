module Veewee
  module Provider
    module Parallels
      module BoxCommand

        def running?
          command="prlctl list -i '#{self.name}'"
          shell_results=shell_exec("#{command}",{:mute => true})
          running=shell_results.stdout.split(/\n/).grep(/^State: running/).size!=0

          env.logger.info("Vm running? #{running}")
          return running
        end

        # Check if box is running
        def exists?

          command="prlctl list --all "
          shell_results=shell_exec("#{command}",{:mute => true})
          exists=shell_results.stdout.split(/\n/).grep(/ #{name}$/).size!=0

          env.logger.info("Vm exists? #{exists}")
          return exists
        end
      end
    end
  end
end
