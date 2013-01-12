require 'test/unit'

require 'rd/block-element'
require 'rd/inline-element'
require 'rd/rd-struct'

include RD

class TestTextBlock < Test::Unit::TestCase
  def setup
    @p = TextBlock.new
    @c1 = StringElement.new "string"
    @c2 = Emphasis.new
    @c21 = StringElement.new "in emphasis"
    @c2.add_child_under_document_struct(@c21, DocumentStructure::RD)
    @c3 = Code.new
    @c31 = StringElement.new "code"
    @c32 = Var.new
    @c321 = StringElement.new "var"
    @c32.add_child_under_document_struct(@c321, DocumentStructure::RD)
    @c3.add_children_under_document_struct([@c31, @c32], DocumentStructure::RD)
    @c4 = Verb.new "verb"
    @p.add_children_under_document_struct([@c1, @c2, @c3, @c4],
                                          DocumentStructure::RD)
  end

  def test_each_child
    exp = [@c1, @c2, @c3, @c4]
    i = 0
    @p.each_child do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_each_element
    exp = [@p, @c1, @c2, @c21, @c3, @c31, @c32, @c321, @c4]
    i = 0
    @p.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end
end
