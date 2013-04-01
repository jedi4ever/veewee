module Veewee
  class Error < StandardError
    attr_reader :original

    def initialize(msg, original = $!)
      super(msg)
      @original = original
    end

  end

  class DefinitionError < Error
  end

  class DefinitionNotExist < DefinitionError
  end

  class TemplateError < Error
  end

  class SshError < Error
  end

  class WinrmError < Error
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
