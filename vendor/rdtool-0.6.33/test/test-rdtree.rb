require 'test/unit'

require 'rd/rdfmt'
require 'rd/element'

include RD

class TestRDTree < Test::Unit::TestCase
  def test_s_new
    tr = RDTree.new("=begin\nTEST\n=end\n")
    assert_kind_of(DocumentElement, tr.root)

    tr_not_parse = RDTree.new("=begin\nTEST\n=end\n", ["test/data"], false)
    assert_nil(tr_not_parse.root)
    assert_equal(["test/data"], tr_not_parse.include_paths)
  end
end
