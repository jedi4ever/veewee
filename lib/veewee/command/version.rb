module Veewee
  module Command
    class VersionCommand < Base

      register "version", "Prints the Veewee version information"
      class_option :includes, :type => :array, :default => ["aa"], :aliases => "-i"
      class_option :excludes, :type => :array, :default => ["aa"], :aliases => "-e"
      def execute
      require 'pp'
        pp options
        env.ui.info "Version : #{Veewee::VERSION} - use at your own risk"
      end

    end

  end
end
