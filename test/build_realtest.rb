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
    @box=@ve.providers["virtualbox"].get_box(@box_name)
  end

  # First build of box
  # - the creation
  # - kickstart fetch
  # - postinstall execution
  def test_box_1_build
    assert_nothing_raised {
      @box.build({'auto' => true,'force' => true, 'nogui' => true , 'disk_count' => 2})
      #@box.build({"auto" => true,"force" => true })
    }
  end

  # Run an ssh command
  def test_box_2_ssh
    assert_nothing_raised {
      result=@box.exec("who am i")
      assert_match(/root/,result.stdout)
    }
  end

  # Type on console
  def test_box_3_console_type
    assert_nothing_raised {
      @box.console_type(['echo "bla" > console.txt<Enter>'])
      result=@box.exec("cat console.txt")
      assert_match(/bla/,result.stdout)
    }
  end

  # Are there as many disks as in disk_count?
  def test_box_4_check_disk_count
    assert_nothing_raised {
      result=@box.exec("lsblk -lo MODEL|grep -i harddisk|wc -l")
      assert_match(/#{@box.definition.disk_count}/,result.stdout)
    }
  end


  # Try shutdown
  def test_box_5_shutdown
    assert_nothing_raised {
      @box.halt
    }
  end

  # Now try build again (with no force flag)
  def test_box_6_build
    #assert_raise(Veewee::Error) {
    assert_nothing_raised {
      #@box.build({"auto" => true})
      @box.build({"auto" => true,'force' => true, 'nogui' => true })
    }
  end

  def test_box_7_destroy
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
