require 'test/unit'

require 'rd/list.rb'
require 'rd/rd-struct'

include RD

class TestListItem < Test::Unit::TestCase
  def setup
    @a = ItemListItem.new
    @c1 = TextBlock.new
    @c2 = TextBlock.new
    @a.add_children_under_document_struct([@c1, @c2], DocumentStructure::RD)

    @b = ItemListItem.new
    @d1 = TextBlock.new
    @d11 = Emphasis.new
    @d1.add_child_under_document_struct(@d11, DocumentStructure::RD)
    @b.add_children_under_document_struct([@d1], DocumentStructure::RD)
  end
  
  def test_each_block
    exp = [@c1, @c2]
    i = 0
    @a.each_block do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@d1]
    i = 0
    @b.each_block do |b|
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
