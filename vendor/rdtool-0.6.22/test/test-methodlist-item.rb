require 'test/unit'

require 'rd/methodlist'
require 'rd/rd-struct'

include RD

class TestMethodListItem < Test::Unit::TestCase
  def test_set_term
    p = MethodListItem.new
    c = MethodListItem::Term.new
    p.set_term_under_document_struct(c, DocumentStructure::RD)
    assert_equal(c, p.term)
    assert_equal(p, c.parent)
  end

  def test_make_term
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    di, dt = nil
    de.build do
      new MethodList do
        di = new MethodListItem do
          dt = make_term
        end
      end
    end
    assert_equal("<RD::MethodListItem>\n  <RD::MethodListItem::Term>",
                 di.inspect)
    assert_equal(di.term, dt)
  end

  def test_inspect
    mi = MethodListItem.new
    mt = MethodListItem::Term.new
    se = StringElement.new "string"
    tb = TextBlock.new
    mi.set_term_under_document_struct(mt, DocumentStructure::RD)
    mi.add_child_under_document_struct(tb, DocumentStructure::RD)
    assert_equal("<RD::MethodListItem>\n  <RD::MethodListItem::Term>\n" +
                 "  <RD::TextBlock>", mi.inspect)
    
    mi_no_desc = MethodListItem.new
    mt_no_desc = MethodListItem::Term.new
    mi_no_desc.set_term_under_document_struct(mt_no_desc,
                                              DocumentStructure::RD)
    assert_equal("<RD::MethodListItem>\n  <RD::MethodListItem::Term>",
                 mi_no_desc.inspect)

    mi_no_term = MethodListItem.new
    mi_no_term.add_child_under_document_struct(TextBlock.new,
                                               DocumentStructure::RD)
    assert_equal("<RD::MethodListItem>\n  <RD::TextBlock>",
                 mi_no_term.inspect)
    assert_equal("<RD::MethodListItem>", MethodListItem.new.inspect)
  end

end

class TestMethodListItemTerm < Test::Unit::TestCase
  def test_to_label
    assert_equal("", MethodListItem::Term.new.to_label)
    assert_equal("foo", MethodListItem::Term.new("foo").to_label)
    assert_equal("foo", MethodListItem::Term.new("foo()").to_label)
    assert_equal("foo", MethodListItem::Term.new("foo(arg)").to_label)
    assert_equal("Foo#foo", MethodListItem::Term.new("Foo#foo(arg)").to_label)
    assert_equal("Foo::foo", MethodListItem::Term.new("Foo::foo(arg)").to_label)    
    assert_equal("foo", MethodListItem::Term.new("foo{|arg| ...}").to_label)
    assert_equal("foo", MethodListItem::Term.new("foo(arg){|arg| ...}").to_label)
    assert_equal("foo", MethodListItem::Term.new("foo  (arg)").to_label)
  end
end
