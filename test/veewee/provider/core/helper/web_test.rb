`VBoxManage -v` rescue nil
if $?.success?

require 'test/unit'
require 'veewee'

class TestVeeweeDownload < Test::Unit::TestCase
  def setup
    @definition_dir = File.expand_path("../../../../../definitions", __FILE__)
    @definition_name = "erb_definition"
    ve = Veewee::Environment.new({ :definition_dir =>  @definition_dir })
    @box = ve.providers["virtualbox"].get_box(@definition_name)
  end

  def test_box_1_build
    assert_equal(
      "\
#!/bin/bash

echo \"Testing one Linux26\"

echo DVD

",
      @box.send(:read_content, File.join(@definition_dir, @definition_name, "autorun0.erb"))
    )
  end
end

end
