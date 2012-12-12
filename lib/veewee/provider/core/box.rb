require 'veewee/provider/core/helper/tcp'
require 'veewee/provider/core/helper/ssh'
require 'veewee/provider/core/helper/web'
require 'veewee/provider/core/helper/shell'
require 'veewee/provider/core/helper/iso'
require 'veewee/provider/core/helper/comm'

require 'veewee/provider/core/box/build'
require 'veewee/provider/core/box/scp'
require 'veewee/provider/core/box/copy'
require 'veewee/provider/core/box/exec'
require 'veewee/provider/core/box/poweroff'
require 'veewee/provider/core/box/halt'
require 'veewee/provider/core/box/sudo'
require 'veewee/provider/core/box/ssh'
require 'veewee/provider/core/box/issh'


require 'veewee/provider/core/box/floppy'
require 'veewee/provider/core/box/validate_tags'

module Veewee
  module Provider
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :env
        attr_accessor :name
        attr_accessor :provider

        include ::Veewee::Provider::Core::Helper::Tcp
        include ::Veewee::Provider::Core::Helper::Web
        include ::Veewee::Provider::Core::Helper::Shell
        include ::Veewee::Provider::Core::Helper::Ssh
        include ::Veewee::Provider::Core::Helper::Comm
        include ::Veewee::Provider::Core::Helper::Iso

        include ::Veewee::Provider::Core::BoxCommand

        def ui
          return @_ui if defined?(@_ui)
          @_ui = @env.ui.dup
          @_ui.resource = @name
          @_ui
        end

        def initialize(name,env)
          @env=env
          @name=name
          self.set_definition(name)
        end

        def gem_available?(gemname)
          env.logger.info "Checking for gem #{gemname}"
          available=false
          begin
            available=true unless Gem::Specification::find_by_name("#{gemname}").nil?
          rescue Gem::LoadError
            env.logger.info "Error loading gem #{gemname}"
            available=false
          rescue
            env.logger.info "Falling back to old syntax for #{gemname}"
            available=Gem.available?("#{gemname}")
            env.logger.info "Old syntax #{gemname}.available? #{available}"
          end
          return available
        end

        def set_definition(definition_name)
          @definition=env.definitions[definition_name]

          unless @definition.nil?
            # We check for windows as em-winrm is not available on ruby1.9
            is_windows =  @definition.os_type_id.start_with?('Windows')

            # On windows systems
            if is_windows
              # Check if winrm is available
              if gem_available?('em-winrm')
                require 'veewee/provider/core/box/winrm'
                require 'veewee/provider/core/helper/winrm'
                require 'veewee/provider/core/box/wincp'

                self.class.send(:include, ::Veewee::Provider::Core::Helper::Winrm)
              else
                raise Veewee::Error, "\nTo build a windows basebox you need to install the gem 'em-winrm' first"
              end
            end
          else
            raise Veewee::Error, "definition '#{definition_name}' does not exist. Are you sure you are in the top directory?"
          end

          return self
        end

        def reload
          @raw=nil
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
