require 'test/unit'

require 'rd/inline-element'

include RD

class TestStringElement < Test::Unit::TestCase
  def test_to_label
    el = StringElement.new "label"
    assert_equal("label", el.to_label)
    ws = StringElement.new " label "
    assert_equal(" label ", ws.to_label)
    empty = StringElement.new ""
    assert_equal("", empty.to_label)    
  end

  def test_content
    el = StringElement.new ""
    assert_equal("", el.content)
    el.content = "label"
    assert_equal("label", el.content)
  end
end

class TestVerb < Test::Unit::TestCase
  def test_to_label
    el = Verb.new "label"
    assert_equal("label", el.to_label)
    ws = Verb.new " label "
    assert_equal("label", ws.to_label)
    empty = Verb.new ""
    assert_equal("", empty.to_label)    
  end

  def test_content
    el = Verb.new ""
    assert_equal("", el.content)
    el.content = "label"
    assert_equal("label", el.content)
  end
end
