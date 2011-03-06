require 'test/unit'

require 'rd/tree'
require 'rd/element'
require 'rd/rd-struct'
require 'rd/loose-struct'

include RD

class TestTree < Test::Unit::TestCase
  def test_new_with_document_struct
    tr = Tree.new_with_document_struct(DocumentStructure::RD, ["test/data"])
    assert_equal(nil, tr.root)
    assert_equal(["test/data"], tr.include_paths)
  end

  def test_set_root
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.set_root(de)
    assert_equal(de, tr.root)
    assert_equal(tr, de.tree)    
  end

  def test_each_element
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    exp = [de]
    i = 0
    tr.each_element do |b|
      assert_equal(exp[i], b)
    end
    
    tr_emp = Tree.new_with_document_struct(DocumentStructure::RD)
    assert_equal(nil, tr_emp.each_element)
  end

  def test_make_root
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    res = tr.make_root
    assert(tr.root)
    assert_equal(tr.root, res)
    
    tr2 = Tree.new_with_document_struct(DocumentStructure::RD)
    res2 = tr2.make_root do
      new TextBlock
    end
    assert(tr2.root)
    assert_equal("<RD::DocumentElement>\n  <RD::TextBlock>", tr2.root.inspect)
    assert_equal(tr2.root, res2)
  end

  def test_check_valid
    tr = Tree.new_with_document_struct(DocumentStructure::RD)
    de = DocumentElement.new
    tr.root = de
    de.build do
      new Headline, 1 do
        new StringElement, "label"
      end
      new TextBlock do
        new Emphasis do
          new StringElement, "emphasis"
        end
      end
    end
    assert_equal(true, tr.check_valid)

    tr_fail = Tree.new_with_document_struct(DocumentStructure::RD)
    de_fail = DocumentElement.new
    tr_fail.root = de_fail
    tb_fail = TextBlock.new
    tb_fail.build(DocumentStructure::LOOSE) do
      new Headline, 1
    end
    de_fail.add_child(tb_fail)
    assert_raises(RuntimeError) do
      tr_fail.check_valid
    end
  end
end
