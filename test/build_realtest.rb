require 'test/unit'
require 'veewee'

class TestVeeweeBuild < Test::Unit::TestCase
  def setup
    definition_dir=File.expand_path(File.join(File.dirname(__FILE__),"definitions"))
    #ENV['VEEWEE_LOG']="STDOUT"
    @ve=Veewee::Environment.new({ :definition_dir =>  definition_dir })
    @definition_name="test_definition"
    @vd=@ve.definitions[@definition_name]
    @box_name=@definition_name
    @vd.postinstall_files=["_test_me.sh"]
    @box=@ve.providers["vmfusion"].get_box(@box_name)
  end

  # First build of box
  # - the creation
  # - kickstart fetch
  # - postinstall execution
  def test_box_1_build
    assert_nothing_raised {
      #@box.build({"auto" => true,:force => true, #:nogui => true })
      @box.build({"auto" => true,:force => true })
    }
  end

  # Run an ssh command
  def test_box_2_ssh
    assert_nothing_raised {
      result=@box.ssh("who am i")
      assert_match(/root/,result.stdout)
    }
  end

  # Type on console
  def test_box_3_console_type
    assert_nothing_raised {
      @box.console_type(['echo "bla" > console.txt<Enter>'])
      result=@box.ssh("cat console.txt")
      assert_match(/bla/,result.stdout)
    }
  end

  # Try shutdown
  def test_box_4_shutdown
    assert_nothing_raised {
      @box.shutdown
    }
  end

  # Now try build again (with no force flag)
  def test_box_5_build
    assert_raise(Veewee::Error) {
      @box.build({"auto" => true})
      #@box.build({"auto" => true,:force => true, :nogui => true })
    }
  end

  def test_box_6_destroy
    assert_nothing_raised {
      @box.destroy
    }
  end

  #
  #  def teardown
  #    #@ve.destroy(@vm_name,@vd)
  #
  #  end

end
