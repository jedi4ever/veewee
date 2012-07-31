module Fission
  class Response
    attr_accessor :code, :output, :data

    def initialize(args={})
      @code = args.fetch :code, 1
      @output = args.fetch :output, ''
      @data = args.fetch :data, nil
    end

    def successful?
      @code == 0
    end

  end
end
