require 'test/unit'
require 'veewee/provider/virtualbox/box/helper/version'
require 'logger'

class TestVboxGuestAdditionsHelper < Test::Unit::TestCase
  include Veewee::Provider::Virtualbox::BoxCommand

  def affected_versions
    {
      "4.2.1" => "4.2.0",
      "4.1.23" => "4.1.22"
    }
  end

  def test_affected_osx_version_returns_downpatched_ga_version
    set_ruby_platform("darwin")
    affected_versions.each do |vbox_version, guest_version|
      set_vbox_version(vbox_version)
      assert_equal(guest_version, self.vboxga_version)
    end
  end

  def test_unaffected_osx_version_returns_same_version
    set_ruby_platform("darwin")
    set_vbox_version("4.1.22")
    assert_equal("4.1.22", self.vboxga_version)
  end

  def test_affected_linux_version_returns_same_version
    set_ruby_platform("linux")
    affected_versions.keys.each do |version|
      set_vbox_version(version)
      assert_equal(version, self.vboxga_version)
    end
  end

  def test_unaffected_linux_version_returns_same_version
    set_ruby_platform("linux")
    set_vbox_version("4.0.19")
    assert_equal("4.0.19", self.vboxga_version)
  end

  def test_affected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    affected_versions.keys.each do |version|
      set_vbox_version(version)
      assert_equal(version, self.vboxga_version)
    end
  end

  def test_unaffected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    set_vbox_version("4.0.19")
    assert_equal("4.0.19", self.vboxga_version)
  end

private
  def set_ruby_platform(platform)
    Object.const_set("RUBY_PLATFORM", platform)
  end

  def set_vbox_version(ver)
    Veewee::Provider::Virtualbox::BoxCommand.send(:define_method, :vbox_version) do
      ver
    end
  end
end
