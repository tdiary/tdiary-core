require 'test/unit'

require 'rd/rbl-suite'
require 'rd/rbl-file'

include RD

class TestRBLSuite < Test::Unit::TestCase
  
  def setup
    @suite = RBLSuite.new(["test/data"])
  end

  def test_get_rbl_file
    assert_equal([], @suite.rbl_files)
    rbl = @suite.get_rbl_file("label.rd")
    assert_equal(rbl, @suite.get_rbl_file("label.rd"))
    assert_equal(1, @suite.rbl_files.size)
  end

  def test_add_rbl_file
    assert_equal([], @suite.rbl_files)
    rbl = @suite.add_rbl_file("label.rd")
    assert_kind_of(RBLFile, rbl)
    assert_equal(1, @suite.rbl_files.size)
    assert_equal("label", @suite.rbl_files[0].filename)
    assert_equal(rbl, @suite.rbl_files[0])

    assert_nothing_raised do
      @suite.add_rbl_file("not-exist-label.rd")
    end
  end

  def test_refer
    assert_equal(["label", "label:0"], @suite.refer("label1", "label.rd"))
    assert_equal(["label2", "Label-0"], @suite.refer("label1", "label2.rd"))
    assert_equal(["label", "label:0"], @suite.refer("label1", "label"))
    assert_equal(["label", "label:1"], @suite.refer("label2", "label.rd"))
    assert_equal(["label", nil], @suite.refer("label3", "label.rd"))
    fns = @suite.rbl_files.collect{|i| i.filename }
    assert_equal(["label", "label2"], fns)
  end
end
