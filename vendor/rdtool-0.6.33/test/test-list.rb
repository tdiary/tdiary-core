require 'test/unit'

require 'rd/list.rb'
require 'rd/rd-struct'

include RD

class TestList < Test::Unit::TestCase
  def setup
    @a = ItemList.new
    @c1 = ItemListItem.new
    @c2 = ItemListItem.new
    @a.add_children_under_document_struct([@c1, @c2], DocumentStructure::RD)

    @b = ItemList.new
    @d1 = ItemListItem.new
    @d11 = TextBlock.new
    @d1.add_child_under_document_struct(@d11, DocumentStructure::RD)
    @b.add_children_under_document_struct([@d1], DocumentStructure::RD)
  end
  
  def test_each_item
    exp = [@c1, @c2]
    i = 0
    @a.each_item do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@d1]
    i = 0
    @b.each_item do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_each_element
    exp = [@a, @c1, @c2]
    i = 0
    @a.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@b, @d1, @d11]
    i = 0
    @b.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end
end
