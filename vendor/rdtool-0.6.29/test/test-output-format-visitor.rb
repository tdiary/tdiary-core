require 'test/unit'

require 'temp-dir'

require 'rd/output-format-visitor'
require 'rd/tree'
require 'rd/element'
require 'rd/block-element'
require 'rd/inline-element'
require 'rd/rd-struct'

include RD

class TestOFVisitor < Test::Unit::TestCase
  def setup
  end

  def test_initialize
    vis = OutputFormatVisitor.new
    assert_equal([], vis.include_suffix)
    vis = SampleVisitor.new
    assert_equal(["html"], vis.include_suffix)    
  end

  def test_apply_to_include
    tree = Tree.new_with_document_struct(DocumentStructure::RD,
                                         ["test/data/sub", "test/data/"])
    de = DocumentElement.new
    # test/data/includee1.html
    inc1 = Include.new("includee1")
    # test/data/includee2.html, test/data/sub/includee2.html
    inc2 = Include.new("includee2")
    # test/data/includee3.nothtml
    inc3 = Include.new("includee3")
    tree.root = de
    de.add_child(inc1)
    de.add_child(inc2)
    de.add_child(inc3)
    vis = SampleVisitor.new
    assert_equal("includee1.html", vis.apply_to_Include(inc1))
    assert_equal("sub/includee2.html", vis.apply_to_Include(inc2))
    assert_equal(nil, vis.apply_to_Include(inc3))
  end
end

class SampleVisitor < OutputFormatVisitor
  INCLUDE_SUFFIX = ["html"]
end
