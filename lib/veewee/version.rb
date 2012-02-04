# Initialize the Module Veewee, otherwise it can't be checked
module Veewee
end

# Only set the version constant if it wasn't set before
unless defined?(Veewee::VERSION)
  ::Veewee::VERSION="0.3.0.alpha4"
end
