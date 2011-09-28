module Veewee
    class Error < StandardError
      attr_reader :orginal
      def initialize(msg, original=$!)
        super(msg)
        @original = original; end
    end
end

#Usage (from the exceptional ruby book)
#begin
#   begin
#     raise "Error A"
#   rescue => error
#     raise MyError, "Error B"
#   end
#rescue => error 
#   env.ui.info "Current failure: #{error.inspect}"
#   env.ui.info "Original failure: #{error.original.inspect}"
#end
