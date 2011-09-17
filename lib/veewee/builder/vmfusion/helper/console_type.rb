require 'veewee/util/scancode'
require 'veewee/util/tcp'
require 'veewee/util/shell'
require 'net/vnc'

module Veewee
  module Builder
    module Vmfusion
      def console_type(sequence,type_options={})
                sequence.each { |s|
        s.gsub!(/%IP%/,Veewee::Util::Tcp.local_ip);
        s.gsub!(/%PORT%/,@definition.kickstart_port);
        s.gsub!(/%NAME%/, @box_name);
      }
        vnc_type(sequence,"localhost",20)
        
      end



    end #Module
  end #Module
end #Module

