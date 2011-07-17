require 'test/unit'
require 'lib/veewee'

class TestVeeweeSession < Test::Unit::TestCase
  def test_session_default_to_currentdir
    
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    begin
      vs=Veewee::Session.new()
      assert_equal(vs.session_dir,tempdir)
    ensure
      FileUtils.remove_entry_secure tempdir
    end
    
  end

  # If a session_dir is passed, it take precendence over currentdir
  def test_session_override_sessiondir

    # Create a temp directory to simulate a currentdir
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    # Now change to another dir
    Dir.chdir("/tmp")
    begin
      vs=Veewee::Session.new({:session_dir => tempdir})
      assert_equal(vs.session_dir,tempdir)
    ensure
      FileUtils.remove_entry_secure tempdir
    end
    
  end

  # parent of isodir or definitiondir not writeable should raise an error
  def test_session_parentdir_should_be_writeable
  end

  # definition_dir , iso_dir by default are relative to the sessiondir
  def test_session_iso_dir_relative_to_sessiondir

    # Create a temp directory to simulate a currentdir
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    begin
      vs=Veewee::Session.new({:session_dir => tempdir})
      assert_equal(vs.definition_dir,File.join(tempdir,"definitions"))
      assert_equal(vs.iso_dir,File.join(tempdir,"iso"))
    ensure
      FileUtils.remove_entry_secure tempdir
    end
    
  end

  # definition_dir , iso_dir  by default are relative to the sessiondir
  def test_session_definition_dir_relative_to_sessiondir
    # Goto top dir , to make pwd another dir
    Dir.chdir("/")
    vs=Veewee::Session.new({:definition_dir => "/tmp"})
    assert_equal(vs.definition_dir,"/tmp")
  end

end