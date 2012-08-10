require 'test/unit'

require 'rd/inline-element'
require 'rd/document-struct'
require 'dummy'

include RD

DummyStruct.define_relationship(NonterminalInline, DummyElement)

class TestNonterminalInline < Test::Unit::TestCase
  def test_children
    el = NonterminalInline.new
    assert_equal([], el.children)
    el.children.push 1
    assert_equal([1], el.children)
  end

  def test_to_label
    one = NonterminalInline.new
    one.add_child_under_document_struct(DummyElement.new, DummyStruct)
    assert_equal("label", one.to_label)

    two = NonterminalInline.new
    two.add_child_under_document_struct(DummyElement.new, DummyStruct)
    two.add_child_under_document_struct(DummyElement.new, DummyStruct)
    assert_equal("label  label", two.to_label)

    zero = NonterminalInline.new
    assert_equal("", zero.to_label)
  end
end

