require 'test/unit'
require 'lib/veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def test_virtualbox_assemble
    assert_nothing_raised {
      vs=Veewee::Session.new({:definition_dir => File.expand_path(File.join(File.dirname(__FILE__),"definitions")) })  
      template_name="test_definition"
      vm_name="test_definition"
      vd=vs.get_definition(template_name)
      vd.postinstall_files=["_test_me.sh"]
      vs.build(vm_name,vd)
      vs.destroy(vm_name,vd)
    }
  end
end