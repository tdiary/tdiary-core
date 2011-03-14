require 'test/unit'

require 'rd/version'

include RD

class TestVersion < Test::Unit::TestCase
  def test_s_new_from_version_string
    ver011 = Version.new_from_version_string("name", "$Version: 0.1.1$") # "
    assert_equal("name", ver011.name)
    assert_equal(0, ver011.major)
    assert_equal(1, ver011.minor)
    assert_equal(1, ver011.patch_level)

    ver0101 = Version.new_from_version_string("name", "$Version: 0.10.1$") #"
    assert_equal(0, ver0101.major)
    assert_equal(10, ver0101.minor)
    assert_equal(1, ver0101.patch_level)

    ver01 = Version.new_from_version_string("name", "$Version: 0.1$") # "
    assert_equal(0, ver01.major)
    assert_equal(1, ver01.minor)
    assert_equal(nil, ver01.patch_level)

    ver0 = Version.new_from_version_string("name", "$Version: 0$") # "
    assert_equal(0, ver0.major)
    assert_equal(nil, ver0.minor)
    assert_equal(nil, ver0.patch_level)
    
    ver011_2 = Version.new_from_version_string("name", "0.1.1") # "
    assert_equal("name", ver011_2.name)
    assert_equal(0, ver011_2.major)
    assert_equal(1, ver011_2.minor)
    assert_equal(1, ver011_2.patch_level)
  end

  def test_s_clean_up_version_string
    assert_equal("0.1.1",
                 Version.clean_up_version_string("$Version: 0.1.1$")) #"
    assert_equal("0.1.1",
                 Version.clean_up_version_string("0.1.1"))
    assert_equal("", Version.clean_up_version_string("$Version$")) # "
  end

  def test_to_s
    ver011 = Version.new("name", 0, 1, 1)
    assert_equal("name 0.1.1", ver011.to_s)
    ver0101 = Version.new("name", 0, 10, 1)
    assert_equal("name 0.10.1", ver0101.to_s)

    ver01 = Version.new("name", 0, 1, nil)
    assert_equal("name 0.1", ver01.to_s)

    ver0 = Version.new("name", 0, nil, nil)
    assert_equal("name 0", ver0.to_s)
  end
end
