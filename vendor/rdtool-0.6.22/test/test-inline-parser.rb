require 'test/unit'

require 'rd/rdinlineparser.tab'
require 'rd/rd-struct'

include RD

class TestInlineParser < Test::Unit::TestCase
  def setup
    @block_parser = RDParser.new
    @tree = tree = Tree.new_with_document_struct(DocumentStructure::RD)
    @block_parser.instance_eval do
      @tree = tree
    end

    @inline_parser = RDInlineParser.new(@block_parser)
  end

  def test_tree
    assert_equal(@tree, @inline_parser.tree)
  end

  def test_make_reference_from_label
    label = Reference::TemporaryLabel.new([StringElement.new("label")])
    expect = Reference.new_from_label_under_document_struct(label,
                        DocumentStructure::RD)
    ref = @inline_parser.make_reference_from_label(label)
    assert_equal(expect.label.element_label, ref.label.element_label)
    assert_equal(expect.label.filename, ref.label.filename)
  end

  def test_prev_words_on_error
    @inline_parser.instance_eval{@pre="foo bar baz"}
    assert_equal("foo bar baz", @inline_parser.prev_words_on_error("foo"))
    assert_equal("foo bar ", @inline_parser.prev_words_on_error("baz"))
    assert_equal("foo bar baz", @inline_parser.prev_words_on_error(false))
    assert_equal("foo bar baz", @inline_parser.prev_words_on_error("not exist"))
    @inline_parser.instance_eval{@pre="foo bar\nfoo2 bar2"}
    assert_equal("foo2 bar2", @inline_parser.prev_words_on_error("foo2"))
    assert_equal("foo2 ", @inline_parser.prev_words_on_error("bar2"))

    @inline_parser.instance_eval{@pre="foo?"}
    assert_equal("foo", @inline_parser.prev_words_on_error("?"))
  end
end

