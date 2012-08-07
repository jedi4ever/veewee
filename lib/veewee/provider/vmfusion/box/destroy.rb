module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def destroy(options={})
          unless raw.exists?
            raise Veewee::Error, "Error:: You tried to destroy a non-existing box '#{name}'"
          end

          raw.halt if raw.state=="running"
          ::Fission::VM.new(name).delete
          # remove it from memory
          @raw=nil
        end
      end
    end
  end
end
