module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def validate_vagrant(options)

          unless self.running?
            ui.error "Error:: You tried to validate box '#{name}' but it is not running"
            exit -1
          end

          require 'cucumber'

          require 'cucumber/rspec/disable_option_parser'
          require 'cucumber/cli/main'

          # Passing ssh options via ENV varialbles to cucumber
          # VEEWEE_SSH_USER, VEEWEE_SSH_PASSWORD ,VEEWEE_SSH_PORT
          cucumber_vars=self.ssh_options
          cucumber_vars.each do |key,value|
            ENV['VEEWEE_'+key.to_s.upcase]=cucumber_vars[key].to_s
          end

          # Pass the name of the box
          ENV['VEEWEE_BOXNAME']=@name
          ENV['VEEWEE_PROVIDER']="virtualbox"

          feature_path=File.join(File.dirname(__FILE__),"..","..","..","..","..","validation","veewee.feature")

          features=Array.new
          features[0]=feature_path
          features[1]="--tags"
          features[2]="@vagrant,@virtualbox"

          begin
            # The dup is to keep ARGV intact, so that tools like ruby-debug can respawn.
            failure = Cucumber::Cli::Main.execute(features.dup)
            Kernel.exit(failure ? 1 : 0)
          rescue SystemExit => e
            Kernel.exit(e.status)
          rescue Exception => e
            ui.error("#{e.message} (#{e.class})")
            ui.error(e.backtrace.join("\n"))
            Kernel.exit(1)
          end

        end
      end #Module

    end #Module
  end #Module
end #Module
