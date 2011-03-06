require 'test/unit'

require 'rd/rdblockparser.tab'
require 'rd/rd-struct'

include RD

class TestBlockParser < Test::Unit::TestCase
  def setup
    @p = RDParser.new
    @p.class.module_eval {
      public :cut_off,:set_term_to_element
    }
    @p.instance_eval do
      @tree = Tree.new_with_document_struct(DocumentStructure::RD)
    end
  end
  
  def test_cut_off
    assert_equal(["aaaa"], @p.cut_off(["aaaa"]))
    assert_equal(["aaaa\n"], @p.cut_off(["aaaa\n"]))
    assert_equal(["aaaa\n"], @p.cut_off(["  aaaa\n"]))
    assert_equal(["aaaa\n", "bbbb\n"], @p.cut_off(["  aaaa\n", "  bbbb\n"]))
    assert_equal(["aaaa\n", "  bbbb\n"], @p.cut_off(["aaaa\n", "  bbbb\n"]))
    assert_equal(["aaaa\n", "  bbbb\n"], @p.cut_off([" aaaa\n", "   bbbb\n"]))
    assert_equal(["aaaa\n", "  bbbb\n", "    cccc\n"],
                 @p.cut_off([" aaaa\n", "   bbbb\n", "     cccc\n"]))
    assert_equal(["aaaa\n", "    bbbb\n", "  cccc\n"],
                 @p.cut_off([" aaaa\n", "     bbbb\n", "   cccc\n"]))
    assert_raises(RuntimeError) do
      @p.cut_off(["  aaaa\n", "bbbb\n"])
    end
  end

  def test_set_term_to_element
    desclist = DescListItem.new
    term = DescListItem::Term.new
    @p.set_term_to_element(desclist, term)
    assert_equal(term, desclist.term)

    methodlist = MethodListItem.new
    term = MethodListItem::Term.new "string"
    @p.set_term_to_element(methodlist, term)
    assert_equal(term, methodlist.term)
  end
end
