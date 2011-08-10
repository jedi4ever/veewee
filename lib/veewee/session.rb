module Veewee

  # This class is here only for backwards compatibility:
  # definition.rb files used to call a static function called declare
  # In the future usage of this class will result in printing deprecated
  class Session < Definition

    def self.declare(options)
      puts "Warning: Definition contains Veewee::Session.declare."
      puts "This syntax is deprecated and should read Veewee::Definition.declare"
      Veewee::Definition.declare(options)
    end

  end

end
