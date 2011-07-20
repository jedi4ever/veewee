require 'veewee/provider/virtualbox/util/scancode'

module Veewee
  module Provider
    module Virtualbox
      def console_type(command)
        send_sequence(command)
      end
end #Module
end #Module
end #Module