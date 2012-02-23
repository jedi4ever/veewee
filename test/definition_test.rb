require 'test/unit'
require 'veewee'

class TestVeeweeDefinition < Test::Unit::TestCase
  def test_environment_load_definition
    # Set the definition dir to our template dir
    ve=Veewee::Environment.new({:definition_dir => [ File.expand_path(File.join(File.dirname(__FILE__),"..", "templates")) ] })
    vd=ve.definitions["ubuntu-10.10-server-amd64"]
    assert_equal(vd.os_type_id,"Ubuntu_64")
  end
end
