module Fission
  class Command
    attr_reader :options, :args

    def initialize(args=[])
      @options = OpenStruct.new
      @args = args
    end

    def self.help
      self.new.option_parser.to_s
    end

  end
end
