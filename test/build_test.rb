require 'test/unit'
require 'lib/veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def setup
          @vs=Veewee::Session.new({:definition_dir => File.expand_path(File.join(File.dirname(__FILE__),"definitions")) })  
          template_name="test_definition"
          @vm_name="test_definition"
          @vd=@vs.get_definition(template_name)
          @vd.postinstall_files=["_test_me.sh"]
          
  end
  
  def test_virtualbox_1_build
    assert_nothing_raised {
      @vs.build(@vm_name,@vd)
    }
  end

  def test_virtualbox_2_ssh
    assert_nothing_raised {
      result=@vs.ssh(@vm_name,@vd,"who am i")
      assert_match(/root/,result.stdout)
    }
  end

  def test_virtualbox_3_console_type
    assert_nothing_raised {
      @vs.console_type(@vm_name,@vd,'echo "bla" > console.txt<Enter>')
      result=@vs.ssh(@vm_name,@vd,"cat console.txt")
      assert_match(/bla/,result.stdout)
    }
  end
  
  def test_virtualbox_4_destroy
    assert_nothing_raised {
      @vs.destroy(@vm_name,@vd)
    }
  end
  
  def teardown
    #@vs.destroy(@vm_name,@vd)
    
  end
  
end