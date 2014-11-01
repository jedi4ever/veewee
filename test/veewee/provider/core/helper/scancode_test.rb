require 'test/unit'
require 'veewee/provider/core/helper/scancode'

class TestVeeweeScancode < Test::Unit::TestCase
  def setup
    @helper = Veewee::Provider::Core::Helper::Scancode
  end

  def test_simple_strings
    assert_equal(
      "1e 9e ",
      @helper.string_to_keycode("a")
    )
  end

  def test_specials
    assert_equal(
      "01 81 ",
      @helper.string_to_keycode("<Esc>")
    )
  end

  def test_specials_lowercase
    assert_equal(
      "01 81 ",
      @helper.string_to_keycode("<esc>")
    )
  end

  def test_spaces
    assert_equal(
      "39 b9 ",
      @helper.string_to_keycode(" ")
    )
  end

  def test_regexps
    assert_equal(
      "wait11 ",
      @helper.string_to_keycode("<Wait11>")
    )
  end

  def test_regexps
    assert_equal(
      "wait ",
      @helper.string_to_keycode("<Wait>")
    )
  end

  def test_combinations
    assert_equal(
      "wait10 01 81 1e 9e 39 b9 30 b0 ",
      @helper.string_to_keycode("<Wait10><Esc>a b")
    )
  end

end
