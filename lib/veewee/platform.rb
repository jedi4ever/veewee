module Veewee
  class Platform

    def initialize(host_os)
      @host_os = host_os.downcase
    end

    def to_native_path(path)
      return cygwin? ? `cygpath --windows "#{path}"`.chomp : path
    end

    def cygwin?
      @host_os.include?('cygwin')
    end

    def self.host
      Platform.new(RbConfig::CONFIG['host_os'])
    end

  end
end
