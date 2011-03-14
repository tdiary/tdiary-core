require 'test/unit'

require 'rd/rdblockparser.tab'
require 'rd/rd-struct'

include RD

class TestParserUtil < Test::Unit::TestCase
  def setup
    @p = RDParser.new
    @tree = tree = Tree.new_with_document_struct(DocumentStructure::RD)
    @p.instance_eval do
      @tree = tree
    end
  end

  def test_tree
    obj = Object.new
    obj.extend(ParserUtility)

    assert_raises(NotImplementedError) do
      obj.tree
    end
  end

  def test_add_children_to_element
    headline = Headline.new(1)
    string_element = StringElement.new "string"
    emphasis = Emphasis.new
    @p.add_children_to_element(headline, string_element, emphasis)
    assert_equal([string_element, emphasis], headline.children)

    textblock = TextBlock.new
    @p.add_children_to_element(textblock, emphasis, string_element)
    assert_equal([emphasis, string_element], textblock.children)

    textblock_empty = TextBlock.new
    @p.add_children_to_element(textblock_empty)
    assert_equal([], textblock_empty.children)
  end
end
