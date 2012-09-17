require 'test/unit'

require 'rd/inline-element'
require 'rd/document-struct'
require 'rd/rd-struct'
require 'rd/loose-struct'
require 'dummy'

include RD

DummyStruct.define_relationship(Reference, DummyElement)

class TestReference < Test::Unit::TestCase
  def test_initialize
    d1 = DummyElement.new
    l = Reference::TemporaryLabel.new([d1])
    ref = Reference.new_from_label_under_document_struct(l, DummyStruct)
    assert_kind_of(Reference::RDLabel, ref.label)
    assert_equal([d1], ref.instance_eval("children"))

    l2 = Reference::TemporaryLabel.new([d1], "filename")
    ref = Reference.new_from_label_under_document_struct(l2, DummyStruct)
    assert_kind_of(Reference::RDLabel, ref.label)
    assert_equal([d1], ref.instance_eval("children"))
    assert_equal("filename", ref.label.filename)

    l = Reference::RDLabel.new("label")
    ref = Reference.new(l)
    assert_kind_of(Reference::RDLabel, ref.label)
    assert_equal([], ref.instance_eval("children"))

    url = Reference::URL.new("label")
    ref2 = Reference.new_from_label_under_document_struct(url,
                                                          DocumentStructure::RD)
    assert_kind_of(Reference::URL, ref2.label)
    assert_kind_of(StringElement, ref2.instance_eval("children")[0])
    assert_equal("<URL:label>", ref2.instance_eval("children")[0].content)
  end

  def test_s_new_from_label_without_document_struct
    se = StringElement.new "string"
    label = Reference::TemporaryLabel.new([se])
    ref = Reference.new_from_label_without_document_struct(label)
    assert_kind_of(Reference::RDLabel, ref.label)
    assert_equal([se], ref.instance_eval("children"))
  end
  
  def test_to_label_RDLabel
    l = Reference::TemporaryLabel.new([DummyElement.new])
    ref = Reference.new(l)
    assert_equal("label", ref.to_label)
  end

  def test_to_label_URL
    l = Reference::URL.new "http://www.ruby-lang.org/"
    ref = Reference.new l
    assert_equal("", ref.to_label)
  end

  def test_result_of_apply_method_of
    visitor = DummyVisitor.new
    label = Reference::RDLabel.new("label")
    reference = Reference.new(label)
    result = ["apply_to_Reference_with_RDLabel",
      [reference, []]]
    assert_equal(result, reference.result_of_apply_method_of(visitor, []))

    url = Reference::URL.new("url")
    reference = Reference.new(url)
    result = ["apply_to_Reference_with_URL",
      [reference, []]]
    assert_equal(result, reference.result_of_apply_method_of(visitor, []))
  end

  def test_add_child
    d1 = DummyElement.new
    d2 = DummyElement.new
    l = Reference::TemporaryLabel.new([d1])
    ref = Reference.new_from_label_under_document_struct(l, DummyStruct)
    ref.add_child_under_document_struct(d2, DummyStruct)
    assert_equal(3, ref.to_a.size)
    assert_equal("label", ref.label.element_label)
  end

  def test_build
    lb = Reference::RDLabel.new("label")
    ref = Reference.new(lb).build(DocumentStructure::LOOSE) do
      set_label(Reference::RDLabel.new("LABEL"))
    end
    assert_equal("LABEL", ref.to_label)
  end
end

class TestRDLabel < Test::Unit::TestCase
  def test_to_label
    one = Reference::RDLabel.new("label")
    assert_equal("label", one.to_label)
    zero = Reference::RDLabel.new("")
    assert_equal("", zero.to_label)
    file = Reference::RDLabel.new("label", "filename")
    assert_equal("label", file.to_label)
  end

  def test_result_of_apply_method_of
    visitor = DummyVisitor.new
    label = Reference::RDLabel.new("label")
    reference = Reference.new(label)
    result = ["apply_to_Reference_with_RDLabel",
      [reference, []]]
    assert_equal(result, label.result_of_apply_method_of(visitor, reference,
                                                         []))
  end
end

class TestURL < Test::Unit::TestCase
  def test_to_label
    nor = Reference::URL.new "http://www.ruby-lang.org/"
    assert_equal("", nor.to_label)
    empty = Reference::URL.new ""
    assert_equal("", empty.to_label)
  end

  def test_result_of_apply_method_of
    visitor = DummyVisitor.new
    label = Reference::URL.new("label")
    reference = Reference.new(label)
    result = ["apply_to_Reference_with_URL",
      [reference, []]]
    assert_equal(result, label.result_of_apply_method_of(visitor, reference,
                                                         []))
  end
end
