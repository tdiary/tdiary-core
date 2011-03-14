require 'test/unit'

require 'rd/tree'
require 'rd/element'
require 'rd/rd-struct'

include RD

class TestElement < Test::Unit::TestCase

  def setup
    @tree = Tree.new_with_document_struct(DocumentStructure::RD)
    @de = DocumentElement.new
    @tree.root = @de
    @tb = TextBlock.new
    @de.add_child(@tb)

    @err = TextBlock.new
  end

  def test_tree
    assert_equal(@tree, @de.tree)
    assert_equal(@tree, @tb.tree)
    assert_raises(RuntimeError) do
      @err.tree
    end
  end

  def test_inspect
    assert_equal("<RD::TextBlock>", TextBlock.new.inspect)

    t = TextBlock.new
    s = StringElement.new ""
    t.add_child_under_document_struct(s, DocumentStructure::RD)
    assert_equal("<RD::TextBlock>\n  <RD::StringElement>", t.inspect)

    t = TextBlock.new
    e = Emphasis.new
    s = StringElement.new ""
    s2 = StringElement.new "a"
    e.add_child_under_document_struct(s, DocumentStructure::RD)
    t.add_children_under_document_struct([e, s2], DocumentStructure::RD)
    exp = "<RD::TextBlock>\n  <RD::Emphasis>\n    <RD::StringElement>\n  <RD::StringElement>"
    assert_equal(exp, t.inspect)
  end
end
