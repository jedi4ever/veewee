require 'veewee/builder/virtualbox/builder'
require 'veewee/builder/vmfusion/builder'
require 'veewee/builder/kvm/builder'

module Veewee

  class BuilderFactory
    def self.instantiate(builder_type,builder_options,environment)
      classname=builder_type.to_s.capitalize
      builder_class=Object.const_get("Veewee").const_get("Builder").const_get(classname).const_get("Builder")
      return builder_class.new(builder_options,environment)
    end
  end

end
