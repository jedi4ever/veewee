require 'veewee/builder/core/definition'

module Veewee::Builder
  module Kvm

    class Definition < ::Veewee::Builder::Core::Definition
      def initialize(name,env)
        super(name,env)
      end
    end
  end
end