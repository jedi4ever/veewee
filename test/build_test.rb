require 'test/unit'
require 'lib/veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def setup
          @ve=Veewee::Environment.new({:definition_dir => File.expand_path(File.join(File.dirname(__FILE__),"definitions")) })  
          template_name="test_definition"
          @vm_name="test_definition"
          @vd=@ve.get_definition(template_name)
          @vd.postinstall_files=["_test_me.sh"]
          require 'pp'  
          pp @vd        
  end
  
  def test_virtualbox_1_build
    assert_nothing_raised {
      @ve.build(@vm_name,@vd)
    }
  end

#  def test_virtualbox_2_ssh
#    assert_nothing_raised {
#      result=@ve.ssh(@vm_name,@vd,"who am i")
#      assert_match(/root/,result.stdout)
#    }
#  end

#  def test_virtualbox_3_console_type
#    assert_nothing_raised {
#      @ve.console_type(@vm_name,@vd,'echo "bla" > console.txt<Enter>')
#      result=@ve.ssh(@vm_name,@vd,"cat console.txt")
#      assert_match(/bla/,result.stdout)
#    }
#  end
  
#  def test_virtualbox_4_destroy
#    assert_nothing_raised {
#      @ve.destroy(@vm_name,@vd)
#    }
#  end
  
  def teardown
    #@ve.destroy(@vm_name,@vd)
    
  end
  
end