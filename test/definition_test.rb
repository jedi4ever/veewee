require 'test/unit'
require 'lib/veewee'

class TestVeeweeDefinition < Test::Unit::TestCase
  def test_environment_load_definition
    # Set the definition dir to our template dir
    ve=Veewee::Environment.new({:definition_path => [ File.expand_path(File.join(File.dirname(__FILE__),"..", "templates")) ] })  
    vd=ve.get_definition("ubuntu-10.10-server-amd64")
    assert_equal(vd.os_type_id,"Ubuntu_64")
  end
end