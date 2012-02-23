module Fission
  class UI
    attr_reader :stdout

    def initialize(stdout=$stdout)
      @stdout = stdout
    end

    def output(s)
      @stdout.puts s
    end

    def output_printf(string, key, value)
      @stdout.send :printf, string, key, value
    end

    def output_and_exit(s, exit_code)
      output s
      exit exit_code
    end
  end
end
