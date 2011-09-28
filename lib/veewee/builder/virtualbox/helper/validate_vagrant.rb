module Veewee
  module Builder
    module Virtualbox
      module BuilderHelper

      def validate_vagrant(box_name,options)
        require 'cucumber'

        require 'cucumber/rspec/disable_option_parser'
        require 'cucumber/cli/main'

        ENV['veewee_user']=options[:user]
        feature_path=File.join(File.dirname(__FILE__),"..","..","..","..","..","validation","vagrant.feature")

        features=Array.new
        features[0]=feature_path

        begin
          # The dup is to keep ARGV intact, so that tools like ruby-debug can respawn.
          failure = Cucumber::Cli::Main.execute(features.dup)
          Kernel.exit(failure ? 1 : 0)
        rescue SystemExit => e
          Kernel.exit(e.status)
        rescue Exception => e
          env.ui.error("#{e.message} (#{e.class})")
          env.ui.error(e.backtrace.join("\n"))
          Kernel.exit(1)
        end

      end
    end #Module
      
    end #Module
  end #Module
end #Module