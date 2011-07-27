require 'veewee/builder/virtualbox/util/scancode'

module Veewee
  module Builder
    module Virtualbox
      def console_type(command,type_options={})
        send_sequence(command)
      end
end #Module
end #Module
end #Module