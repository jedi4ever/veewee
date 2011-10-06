require 'test/unit'
require 'veewee'
require 'tempfile'

class TestVeeweeEnvironment < Test::Unit::TestCase
  def test_environment_default_to_currentdir

    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    begin
      ve=Veewee::Environment.new()
      assert_equal(ve.cwd,tempdir)
    ensure
      FileUtils.remove_entry_secure tempdir
    end

  end

  # If a cwd is passed, it take precendence over currentdir
  def test_environment_override_environmentdir

    # Create a temp directory to simulate a currentdir
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    # Now change to another dir
    Dir.chdir("/tmp")
    begin
      ve=Veewee::Environment.new({:cwd => tempdir})
      assert_equal(ve.cwd,tempdir)
    ensure
      FileUtils.remove_entry_secure tempdir
    end

  end

  # parent of isodir or definitiondir not writeable should raise an error
  def test_environment_parentdir_should_be_writeable
  end

  # definition_dir , iso_dir by default are relative to the environmentdir
  def test_environment_iso_dir_relative_to_environmentdir

    # Create a temp directory to simulate a currentdir
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    tempdir=Dir.pwd
    begin
      ve=Veewee::Environment.new({:cwd => tempdir})
      assert_equal(ve.definition_dir,File.join(tempdir,"definitions"))
      assert_equal(ve.iso_dir,File.join(tempdir,"iso"))
    ensure
      FileUtils.remove_entry_secure tempdir
    end

  end

  # definition_dir , iso_dir  by default are relative to the environmentdir
  def test_environment_definition_dir_relative_to_environmentdir
    # Goto top dir , to make pwd another dir
    Dir.chdir("/")
    ve=Veewee::Environment.new({:definition_dir => "/tmp"})
    assert_equal(ve.definition_dir,"/tmp")
  end

end
