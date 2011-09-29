require 'test/unit'
require 'lib/veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def setup
  definition_dir=File.expand_path(File.join(File.dirname(__FILE__),"definitions"))
      puts definition_dir
    @ve=Veewee::Environment.new({
      :definition_path => [ definition_dir ],
      :definition_dir =>  definition_dir 
 })
    @definition_name="test_definition"
    @vd=@ve.get_definition(@definition_name)
    @box_name="test_definition"
    @vd.postinstall_files=["_test_me.sh"]
  end

  def test_virtualbox_1_build
    assert_nothing_raised {
      @ve.config.builders["virtualbox"].build(@definition_name,@box_name,{"auto" => true,:force => true})
    }
  end

#  def test_virtualbox_2_ssh
#    assert_nothing_raised {
#      result=@ve.config.builders["virtualbox"].get_box(@box_name).ssh("who am i")
#      assert_match(/root/,result.stdout)
#    }
#  end
#
#  def test_virtualbox_3_console_type
#    assert_nothing_raised {
#      @ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).console_type('echo "bla" > console.txt<Enter>')
#      result=@ve.builder(:virtualbox).get_box(@vm_name,@vd,{}).ssh("cat console.txt")
#      assert_match(/bla/,result.stdout)
#    }
#  end
#
#  def test_virtualbox_4_destroy
#    assert_nothing_raised {
#      @ve.config.builders["virtualbox"].get_box(@vm_name,@vd,{}).destroy({})
#    }
#  end
#
#  def teardown
#    #@ve.destroy(@vm_name,@vd)
#
#  end

end
