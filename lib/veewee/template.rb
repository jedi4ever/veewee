module Veewee
  class Template

    attr_accessor :env

    attr_reader :name,:path

    def initialize(name,path,env)
      @name=name
      @path=path
      @env=env
      return self
    end

    def exists?
      filename=Dir.glob("#{path}/definition.rb")
      if filename.length!=0
          env.logger.debug("[Template] template '#{name}' is valid")
          return true
      else
        return false
      end
    end

  end
end
