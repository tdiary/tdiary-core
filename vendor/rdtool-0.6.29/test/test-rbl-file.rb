require 'test/unit'

require 'temp-dir'

require 'rd/rbl-file'
require 'rd/block-element'
require 'rd/inline-element'
require 'rd/rd-struct'
require 'rd/reference-resolver'

include RD

class TestRBLFile < Test::Unit::TestCase
  
  def setup
    tr_head2 = Tree.new_with_document_struct(DocumentStructure::RD)
    de_head2 = DocumentElement.new
    tr_head2.root = de_head2
    hl1_head2, hl2_head2 = nil

    de_head2.build do
      hl1_head2 = new Headline, 1 do
        new StringElement, "label1"
      end
      new TextBlock
      hl2_head2 = new Headline, 2 do
        new StringElement, "label2"
      end
    end

    @resolv_head2 = ReferenceResolver.new(tr_head2, "label:")

    tr_desc = Tree.new_with_document_struct(DocumentStructure::RD)
    de_desc = DocumentElement.new
    tr_desc.root = de_desc
    hl1_desc, dt1_desc = nil
    de_desc.build do
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
    @resolv_desc = ReferenceResolver.new(tr_desc, "Label-")

    tr_empty = Tree.new_with_document_struct(DocumentStructure::RD)
    de_empty = DocumentElement.new
    tr_empty.root = de_empty
    @resolv_empty = ReferenceResolver.new(tr_empty, "LABEL")

    tr_arr = Tree.new_with_document_struct(DocumentStructure::RD)
    de_arr = DocumentElement.new
    tr_arr.root = de_arr

    de_arr.build do
      new Headline, 1 do
        new StringElement, "a => b"
      end
    end

    @resolv_arr = ReferenceResolver.new(tr_arr, "label:")

    @rbl_head2 = RBLFile.new("test-head2")
    @rbl_desc = RBLFile.new("test-desc")
    @rbl_empty = RBLFile.new("test-empty")
    @rbl_arr = RBLFile.new("test-arr")
  end
  
  def test_labels_to_string
    res = "label1 => label:0\nlabel2 => label:1"
    assert_equal(res, RBLFile.labels_to_string(@resolv_head2))

    res2 = "label1 => Label-0\nlabel2 => Label-1"
    assert_equal(res2, RBLFile.labels_to_string(@resolv_desc))

    res_empty = ""
    assert_equal(res_empty, RBLFile.labels_to_string(@resolv_empty))

    res_arr = "a => b => label:0"
    assert_equal(res_arr, RBLFile.labels_to_string(@resolv_arr))
  end

  def test_string_to_labels
    rbl = RBLFile.new("test-head2")
    src_head2 = "label1 => label:0\nlabel2 => label:1"
    res_head2 = [["label1", "label:0"], ["label2", "label:1"]]
    assert_equal(res_head2, rbl.string_to_labels(src_head2)) 

    src_head2 = "label1 =>label:0\nlabel2=> label:1"
    res_head2 = [["label1", "label:0"], ["label2", "label:1"]]
    assert_equal(res_head2, rbl.string_to_labels(src_head2)) 

    src_desc = "label1 => Label-0\nlabel2 => Label-1"
    res_desc = [["label1", "Label-0"], ["label2", "Label-1"]]
    assert_equal(res_desc, rbl.string_to_labels(src_desc)) 

    src_empty = ""
    res_empty = []
    assert_equal(res_empty, @rbl_empty.string_to_labels(src_empty)) 

    src_arr = "a => b => label:0"
    res_arr = [["a => b", "label:0"]]
    assert_equal(res_arr, @rbl_arr.string_to_labels(src_arr)) 
  end

  def test_rbl_file_path
    assert_equal("test-head2.rbl", RBLFile.rbl_file_path("test-head2.rd"))
    assert_equal("test-head2.rbl", RBLFile.rbl_file_path("test-head2.rb"))
    assert_equal("test-desc.rbl", RBLFile.rbl_file_path("test-desc"))
  end

  def test_s_create_rbl_file
    in_temp_dir do
      begin
        RBLFile.create_rbl_file("test-head2.rd", @resolv_head2)
        assert(File.exist?("test-head2.rbl"))
      ensure
        remove_file("test-head2.rbl")
      end
    end
  end

  def test_load_rbl_file
    in_temp_dir do
      spath = [Dir.pwd]
      begin
        RBLFile.create_rbl_file("test-head2.rd", @resolv_head2)

        rbl_rd = RBLFile.new("test-head2.rd")
        rbl_rd.load_rbl_file(spath)
        res = [["label1", "label:0"], ["label2", "label:1"]]
        assert_equal(res, rbl_rd.labels)
        
        rbl_no = RBLFile.new("test-head2")
        rbl_no.load_rbl_file(spath)
        assert_equal(res, rbl_no.labels)
      ensure
        remove_file("test-head2.rbl")
      end
    end
  end

  def test_refer
    spath = ["test/data"]
    rbl = RBLFile.new("label")
    rbl.load_rbl_file(spath)
    assert_equal("label:0", rbl.refer("label1"))
    assert_equal("label:1", rbl.refer("label2"))
    assert_equal(nil, rbl.refer("label3"))
  end
end
