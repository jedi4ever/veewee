module Veewee  
  
  # This class is here only for backwards compatibility
  class BuilderFactory
    def initialize(type,environment)
      @environment=environment
      @classname=type.to_s.capitalize
      return self
    end
    
    def get_box(boxname,definition,builder_options={})
      builder_class=Object.const_get("Veewee").const_get(@classname)
      builder=builder_class.new(boxname,definition,@environment,builder_options)
      return builder
    end
    
  end

end
