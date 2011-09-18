require 'veewee/builder/core/builder'

require 'virtualbox'
#require 'virtualbox/abstract_model'
#require 'virtualbox/ext/byte_normalizer'

require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Virtualbox
    class Builder < Veewee::Builder::Core::Builder

      def list_ostypes(list_options={})
          return VirtualBox::Global.global.lib.virtualbox.guest_os_types
      end

    end #End Class
end # End Module
end # End Module
end # End Module
