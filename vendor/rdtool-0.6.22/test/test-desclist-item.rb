require 'test/unit'

require 'rd/desclist'
require 'rd/rd-struct'

include RD

class TestDescListItem < Test::Unit::TestCase
  def setup
    @flat = DescListItem.new
    @t1 = DescListItem::Term.new
    @flat.set_term_under_document_struct(@t1, DocumentStructure::RD)
    @c1 = TextBlock.new
    @c2 = ItemList.new
    @flat.add_children_under_document_struct([@c1, @c2],
                                             DocumentStructure::RD)

    @nest = DescListItem.new
    @t2 = DescListItem::Term.new
    @t21 = StringElement.new ""
    @t2.add_child_under_document_struct(@t21, DocumentStructure::RD)
    @nest.set_term_under_document_struct(@t2, DocumentStructure::RD)
    @d1 = TextBlock.new
    @d11 = StringElement.new ""
    @d1.add_child_under_document_struct(@d11, DocumentStructure::RD)
    @nest.add_children_under_document_struct([@d1],
                                             DocumentStructure::RD)
  end

  def test_set_term_under_docment_struct
    t = DescListItem::Term.new
    i = DescListItem.new
    i.set_term_under_document_struct(t, DocumentStructure::RD)
    assert_equal(t, i.term)
    assert_equal(i, t.parent)
    
    assert_raises(ArgumentError) do
      t = StringElement.new ""
      DescListItem.new.set_term_under_document_struct(t, DocumentStructure::RD)
    end
  end

  def test_assign_term
    desclist = DescListItem.new
    term = DescListItem::Term.new
    desclist.assign_term(term)
    assert_equal(term, desclist.term)
    assert_equal(desclist, term.parent)
  end

  def test_set_term_without_document_strcut
    desclist = DescListItem.new
    term = DescListItem::Term.new
    desclist.set_term_without_document_struct(term)
    assert_equal(term, desclist.term)
    assert_equal(desclist, term.parent)

    not_term = StringElement.new "not term"
    desclist.set_term_without_document_struct(not_term)
    assert_equal(not_term, desclist.term)
    assert_equal(desclist, not_term.parent)
  end

  def test_each_block_in_description
    exp = [@c1, @c2]
    i = 0
    @flat.each_block_in_description do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@d1]
    i = 0
    @nest.each_block_in_description do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_each_element
    exp = [@flat, @t1, @c1, @c2]
    i = 0
    @flat.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@nest, @t2, @t21, @d1, @d11]
    i = 0
    @nest.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_make_term
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    di, dt = nil
    de.build do
      new DescList do
        di = new DescListItem do
          dt = make_term do
            new StringElement, "string"
          end
        end
      end
    end
    assert_equal("<RD::DescListItem>\n  <RD::DescListItem::Term>\n" +
                 "    <RD::StringElement>", di.inspect)
    assert_equal(di.term, dt)

    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    di, dt = nil
    de.build do
      new DescList do
        di = new DescListItem do
          dt = make_term
        end
      end
    end
    assert_equal(di.term, dt)    
  end

  def test_inspect
    di = DescListItem.new
    dt = DescListItem::Term.new
    se = StringElement.new "string"
    tb = TextBlock.new
    di.set_term_under_document_struct(dt, DocumentStructure::RD)
    di.add_child_under_document_struct(tb, DocumentStructure::RD)
    dt.add_child_under_document_struct(se, DocumentStructure::RD)
    assert_equal("<RD::DescListItem>\n  <RD::DescListItem::Term>\n" +
                 "    <RD::StringElement>\n  <RD::TextBlock>", di.inspect)
    
    di_no_desc = DescListItem.new
    dt_no_desc = DescListItem::Term.new
    di_no_desc.set_term_under_document_struct(dt_no_desc,
                                              DocumentStructure::RD)
    assert_equal("<RD::DescListItem>\n  <RD::DescListItem::Term>",
                 di_no_desc.inspect)

    di_no_term = DescListItem.new
    di_no_term.add_child_under_document_struct(TextBlock.new,
                                               DocumentStructure::RD)
    assert_equal("<RD::DescListItem>\n  <RD::TextBlock>",
                 di_no_term.inspect)
    assert_equal("<RD::DescListItem>", DescListItem.new.inspect)
  end
end

class TestDescListItemTerm < Test::Unit::TestCase
  def setup
    @flat = DescListItem::Term.new
    @c1 = StringElement.new "aaa"
    @c2 = Emphasis.new
    @c3 = StringElement.new " bbb"
    @flat.add_children_under_document_struct([@c1, @c2, @c3],
                                             DocumentStructure::RD)

    @nest = DescListItem::Term.new
    @d1 = StringElement.new "aaa"
    @d2 = Emphasis.new
    @d21 = StringElement.new " bbb"
    @d2.add_child_under_document_struct(@d21, DocumentStructure::RD)
    @nest.add_children_under_document_struct([@d1, @d2],
                                             DocumentStructure::RD)
    @empty = DescListItem::Term.new
  end
  
  def test_each_child
    exp = [@c1, @c2, @c3]
    i = 0
    @flat.each_child do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@d1, @d2]
    i = 0
    @nest.each_child do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_each_element
    exp = [@flat, @c1, @c2, @c3]
    i = 0
    @flat.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@nest, @d1, @d2, @d21]
    i = 0
    @nest.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end

    exp = [@empty]
    i = 0
    @empty.each_element do |b|
      assert_equal(exp[i], b)
      i += 1
    end
  end

  def test_to_label
    assert_equal("aaa bbb", @flat.to_label)
    assert_equal("aaabbb", @nest.to_label)
    assert_equal("", @empty.to_label)
  end
end

