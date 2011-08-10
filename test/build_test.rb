require 'test/unit'
require 'lib/veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def setup
    @ve=Veewee::Environment.new({:definition_dir => File.expand_path(File.join(File.dirname(__FILE__),"definitions")) })
    template_name="test_definition"
    @vm_name="test_definition"
    @vd=@ve.get_definition(template_name)
    @vd.postinstall_files=["_test_me.sh"]
  end

  def test_virtualbox_1_build
    assert_nothing_raised {
      @ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).build({})
    }
  end

  def test_virtualbox_2_ssh
    assert_nothing_raised {
      result=@ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).ssh("who am i")
      assert_match(/root/,result.stdout)
    }
  end

  def test_virtualbox_3_console_type
    assert_nothing_raised {
      @ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).console_type('echo "bla" > console.txt<Enter>')
      result=@ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).ssh("cat console.txt")
      assert_match(/bla/,result.stdout)
    }
  end

  def test_virtualbox_4_destroy
    assert_nothing_raised {
      @ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).destroy({})
    }
  end

  def teardown
    #@ve.destroy(@vm_name,@vd)

  end

end
