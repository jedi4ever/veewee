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

  def test_affected_osx_version_returns_downpatched_ga_version
    set_ruby_platform("darwin")
    set_vbox_version("4.2.1")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.2.0/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.2.0.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
  end

  def test_unaffected_osx_version_returns_same_version
    set_ruby_platform("darwin")
    set_vbox_version("4.1.22")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.1.22/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.1.22.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
  end

  def test_affected_linux_version_returns_same_version
    set_ruby_platform("linux")
    set_vbox_version("4.2.1")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.2.1/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.2.1.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
  end

  def test_unaffected_linux_version_returns_same_version
    set_ruby_platform("linux")
    set_vbox_version("4.0.19")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.0.19/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.0.19.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
  end

  def test_affected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    set_vbox_version("4.2.1")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.2.1/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.2.1.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
  end

  def test_unaffected_mswin_version_returns_same_version
    set_ruby_platform("mswin")
    set_vbox_version("4.0.19")
    def download_iso(url, isofile)
      expected_url_prefix = "http://download.virtualbox.org/virtualbox/4.0.19/"
      assert(url.include?(expected_url_prefix))
      assert_equal("VBoxGuestAdditions_4.0.19.iso", isofile)
    end
    download_vbox_guest_additions_iso({})
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
