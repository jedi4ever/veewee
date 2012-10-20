require 'test/unit'
require 'veewee/provider/virtualbox/box/helper/guest_additions'
require 'veewee/provider/virtualbox/box/helper/version'
require 'logger'

class TestVboxGuestAdditionsHelper < Test::Unit::TestCase
  include Veewee::Provider::Virtualbox::BoxCommand
  def setup
    @fd = IO.sysopen("/dev/null", "w")
  end

  def ui
    @ui ||= Logger.new(IO.new(@fd))
  end

  def affected_versions
    {
      "4.2.1" => "4.2.0",
      "4.1.23" => "4.1.22"
    }
  end

  def verify_version(vbox_version, guest_version, msg="", scope)
    set_vbox_version(vbox_version)

    scope.class.instance_eval do
      define_method :download_iso do |url, isofile|
        expected_url_prefix = "http://download.virtualbox.org/virtualbox/#{guest_version}/"

        assert(url.include?(expected_url_prefix), msg)
        assert_equal("VBoxGuestAdditions_#{guest_version}.iso", isofile, msg)
      end
    end

    download_vbox_guest_additions_iso({})
  end

  def verify_affected_versions(msg="", scope)
    affected_versions.each do |vbox_version, guest_version|
      verify_version(vbox_version, guest_version, msg, scope)
    end
  end

  def test_affected_osx_version_returns_downpatched_ga_version
    set_ruby_platform("darwin")
    msg = "affected osx version did not return downpatched ga version"

    verify_affected_versions(msg, self)
  end

  def test_unaffected_osx_version_returns_same_version
    set_ruby_platform("darwin")
    msg = "unaffected osx version did not return same version"
    verify_version("4.1.22","4.1.22", msg, self)
  end

  def test_affected_linux_version_returns_same_version
    set_ruby_platform("linux")
    msg = "affected linux version did not return same version"
    affected_versions.keys.each do |version|
      verify_version(version, version, msg, self)
    end
  end

  def test_unaffected_linux_version_returns_same_version
    set_ruby_platform("linux")
    msg = "unaffected linux version did not return same version"
    verify_version("4.0.19","4.0.19", msg, self)
  end

  def test_affected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    msg = "affected mswin version did not return same version"
    affected_versions.keys.each do |version|
      verify_version(version, version, msg, self)
    end
  end

  def test_unaffected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    msg = "unaffected mswin version did not return same version"
    verify_version("4.0.19","4.0.19", msg, self)
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
