module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def destroy(options={})
          unless raw.exists?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            exit -1
          end

          raw.halt if raw.state=="running"
          ::Fission::VM.delete(name)
          # remove it from memory
          @raw=nil
        end
      end
    end
  end
end
