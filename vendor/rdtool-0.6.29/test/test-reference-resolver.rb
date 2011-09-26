require 'test/unit'

require 'temp-dir'

require 'rd/reference-resolver'
require 'rd/tree'
require 'rd/rd-struct'

include RD

class TestReferenceResolver < Test::Unit::TestCase
  def setup
    @tr_head1 = Tree.new_with_document_struct(DocumentStructure::RD)
    @de_head1 = DocumentElement.new
    @tr_head1.root = @de_head1

    hl_head1 = nil
    se_head1 = nil
    @de_head1.build do
      hl_head1 = new Headline, 1 do
        se_head1 = new StringElement, "label"
      end
    end
    @hl_head1 = hl_head1
    @se_head1 = se_head1

    @tr_head2 = Tree.new_with_document_struct(DocumentStructure::RD)
    @de_head2 = DocumentElement.new
    @tr_head2.root = @de_head2
    hl1_head2, hl2_head2 = nil

    @de_head2.build do
      hl1_head2 = new Headline, 1 do
        new StringElement, "label1"
      end
      new TextBlock
      hl2_head2 = new Headline, 2 do
        new StringElement, "label2"
      end
    end
    @hl1_head2 = hl1_head2
    @hl2_head2 = hl2_head2

    @tr_desc = Tree.new_with_document_struct(DocumentStructure::RD)
    @de_desc = DocumentElement.new
    @tr_desc.root = @de_desc
    hl1_desc, dt1_desc = nil
    @de_desc.build do
      hl1_desc = new(Headline, 1) do
        new StringElement, "label1"
      end
      new DescList do
        new DescListItem do
          dt1_desc = make_term do
            new StringElement, "label2"
          end
        end
      end
    end
    @hl1_desc = hl1_desc
    @dt1_desc = dt1_desc

    @tr_conf = Tree.new_with_document_struct(DocumentStructure::RD)
    @de_conf = DocumentElement.new
    @tr_conf.root = @de_conf
    hl1_conf, hl2_conf = nil
    @de_conf.build do
      hl1_conf = new Headline, 1 do
        new StringElement, "label"
      end
      hl2_conf = new Headline, 2 do
        new StringElement, "label"
      end
    end
    @hl1_conf = hl1_conf
    @hl2_conf = hl2_conf
    
    @tr_no = Tree.new_with_document_struct(DocumentStructure::RD)
    @de_no = DocumentElement.new
    @tr_no.root = @de_no

    @resolver = ReferenceResolver.new(@tr_head2)
  end

  def test_referent_of_label
    @tr_desc.include_path = ["test/data"]
    resolv = ReferenceResolver.new(@tr_desc, "label:")
    label1 = Reference::RDLabel.new("label1")
    assert_equal([nil, "label:0"], resolv.referent_of_label(label1))
    label2 = Reference::RDLabel.new("label2")    
    assert_equal([nil, "label:1"], resolv.referent_of_label(label2))
    label_ext = Reference::RDLabel.new("label1", "label.rd")
    assert_equal(["label", "label:0"], resolv.referent_of_label(label_ext))

    label3 = Reference::RDLabel.new("label3")
    assert_equal(nil, resolv.referent_of_label(label3))
    label_ext3 = Reference::RDLabel.new("label3", "label.rd")
    assert_equal(["label", nil], resolv.referent_of_label(label_ext3))
  end

  def test_refer_element
    resolv = ReferenceResolver.new(@tr_head1)
    assert_equal([@hl_head1], resolv.refer_element("label"))
    assert_equal([], resolv.refer_element("label not found"))
    resolv = ReferenceResolver.new(@tr_head2)
    assert_equal([@hl1_head2], resolv.refer_element("label1"))
    assert_equal([@hl2_head2], resolv.refer_element("label2"))
    resolv = ReferenceResolver.new(@tr_desc)
    assert_equal([@hl1_desc], resolv.refer_element("label1"))
    assert_equal([@dt1_desc], resolv.refer_element("label2"))
    resolv = ReferenceResolver.new(@tr_conf)
    assert_equal([@hl1_conf, @hl2_conf], resolv.refer_element("label"))
    resolv = ReferenceResolver.new(@tr_no)
    assert_equal([], resolv.refer_element("label"))
  end

  def test_refer
    resolv = ReferenceResolver.new(@tr_head1, "label:")
    assert_equal("label:0", resolv.refer("label"))
    assert_equal(nil, resolv.refer("label not found"))
    resolv = ReferenceResolver.new(@tr_head2, "label:")
    assert_equal("label:0", resolv.refer("label1"))
    assert_equal("label:1", resolv.refer("label2"))
    resolv = ReferenceResolver.new(@tr_desc, "label:")
    assert_equal("label:0", resolv.refer("label1"))
    assert_equal("label:1", resolv.refer("label2"))
    resolv = ReferenceResolver.new(@tr_conf, "label:")
    assert_equal("label:0", resolv.refer("label"))
    resolv = ReferenceResolver.new(@tr_no, "label:")
    assert_equal(nil, resolv.refer("label"))

    resolv = ReferenceResolver.new(@tr_head1, "label:")
    label = Reference::RDLabel.new("label")
    assert_equal("label:0", resolv.refer(label))
    ref = Reference.new(label)
    assert_equal("label:0", resolv.refer(ref))
  end

  def test_refer_external_file
    tr_ext = Tree.new_with_document_struct(DocumentStructure::RD,
                                            ["test/data"])
    label_ext = Reference::RDLabel.new("label1", "label.rd")
    de = DocumentElement.new
    tr_ext.root = de
    ref = nil
    de.build do
      new TextBlock do
        se = StringElement.new "label"
        ref = new Reference, label_ext
      end
    end
    label_not_exist = Reference::RDLabel.new("label3", "label.rd")
    resolv = ReferenceResolver.new(tr_ext)
    
    assert_equal(["label", "label:0"], resolv.refer_external_file(ref))
    assert_equal(["label", "label:0"], resolv.refer_external_file(label_ext))
    assert_equal(["label", nil], resolv.refer_external_file(label_not_exist))
  end

  def test_get_label_num
    assert_equal(0, @resolver.get_label_num(@hl1_head2))
    assert_equal(1, @resolver.get_label_num(@hl2_head2))
    assert_equal(nil, @resolver.get_label_num(@dt1_desc))
  end

  def test_get_anchor
    resolv = ReferenceResolver.new(@tr_head2, "Label-")
    assert_equal("Label-0", resolv.get_anchor(@hl1_head2))
    assert_equal("Label-1", resolv.get_anchor(@hl2_head2))
    assert_equal(nil, resolv.get_anchor(@dt1_desc))
  end

  def test_label2str
    assert_equal("string", @resolver.label2str("string"))
    assert_equal("label", @resolver.label2str(@hl_head1))
    assert_equal("label2", @resolver.label2str(@dt1_desc))
    label = Reference::RDLabel.new("label1")
    assert_equal("label1", @resolver.label2str(label))
    ref = Reference.new(label)
    assert_equal("label1", @resolver.label2str(ref))    
    assert_raises(ArgumentError) do
      @resolver.label2str([])
    end
  end

  def test_make_rbl_file
    in_temp_dir do
      begin
        @resolver.make_rbl_file("label-head")
        assert(File.exist?("label-head.rbl"))
      ensure
        remove_file("label-head.rbl")
      end
      begin
        @resolver.make_rbl_file("label-head2.rd")
        assert(File.exist?("label-head2.rbl"))
      ensure
        remove_file("label-head2.rbl")
      end
    end
  end
end
