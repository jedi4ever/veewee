module Veewee
  module Provider
    module Virtualbox
      module BoxCommand
        UNSYNCED_VERSIONS = {"4.2.1" => "4.2.0", "4.1.23" => "4.1.22"}

        # Return the major/minor/incremental version of VirtualBox.
        # For example: 4.1.8_Debianr75467 -> 4.1.8
        def vbox_version
          command="#{@vboxcmd} --version"
          stderr = "/dev/null"
          is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
          stderr = "nul" if is_windows
          shell_results=shell_exec("#{command}",{:mute => true, :stderr => stderr})
          version=shell_results.stdout.strip.split(/[^0-9\.]/)[0]
          return version
        end

        def vboxga_version
          affected_version?(self.vbox_version) ? UNSYNCED_VERSIONS[self.vbox_version] : self.vbox_version
        end
      protected
        def affected_version?(ver)
          RUBY_PLATFORM.downcase.include?("darwin") && UNSYNCED_VERSIONS.has_key?(ver)
        end
      end
    end
  end
end
