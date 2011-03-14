require 'test/unit'

require 'rd/rdvisitor'
require 'rd/rd-struct'

include RD
class TestRDVisitor < Test::Unit::TestCase

  def test_refer_external
    tr_ext = Tree.new_with_document_struct(DocumentStructure::RD,
                                            ["test/data"])
    label_ext = Reference::RDLabel.new("label1", "label.rd")
    tr_ext.root = DocumentElement.new
    ref_ext = nil
    tr_ext.root.build do
      new TextBlock do
        StringElement.new "label"
        ref_ext = new Reference, label_ext
      end
    end
    vis_ext = RDVisitor.new
    vis_ext.prepare_labels(tr_ext)
    label_not_exist = Reference::RDLabel.new("label3", "label.rd")

    assert_equal("label:0", vis_ext.refer_external(ref_ext))
    assert_equal( "label:0", vis_ext.refer_external(label_ext))
    assert_equal(nil, vis_ext.refer_external(label_not_exist))
  end
end
