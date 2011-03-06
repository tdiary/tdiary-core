require 'test/unit'

require 'rd/element'
require 'rd/rd-struct'

include RD

class TestDocumentElement < Test::Unit::TestCase
  def setup
    @p = DocumentElement.new
    @c1 = Headline.new(1)
    @c2 = TextBlock.new
    @c3 = ItemList.new
    @c31 = ItemListItem.new
    @c311 = TextBlock.new
    @c31.add_child_under_document_struct(@c311, DocumentStructure::RD)
    @c3.add_child_under_document_struct(@c31, DocumentStructure::RD)
    @p.add_children_under_document_struct([@c1, @c2, @c3],
                                            DocumentStructure::RD)
  end
  
  def test_s_new
    assert(DocumentElement.new)
  end

  def test_blocks
    assert_equal([@c1, @c2, @c3], @p.blocks)
  end

  def test_each_block
    i = 1
    @p.each_block do |b|
      assert_equal(eval("@c#{i}"), b)
      i += 1
    end
  end

  def test_each_element
    exp = [@p, @c1, @c2, @c3, @c31, @c311]
    i = 0
    @p.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end
end
