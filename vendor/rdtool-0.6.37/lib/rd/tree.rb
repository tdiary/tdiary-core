require "rd/rdblockparser.tab"
require "rd/filter"
require "rd/document-struct"
require "rd/version"

module RD

  # document tree
  class Tree
    include Enumerable

    SYSTEM_NAME = "RDtool Framework -- Document Tree"
    SYSTEM_VERSION = "$Version: "+RD::VERSION+"$"
    VERSION = Version.new_from_version_string(SYSTEM_NAME, SYSTEM_VERSION)

    def Tree.version
      VERSION
    end

    TMP_DIR = "/tmp"

    def Tree.tmp_dir
      TMP_DIR
    end

    attr_reader :root
    attr_reader :document_struct
    attr_accessor :include_paths
    alias include_path include_paths
    alias include_path= include_paths=
    attr_reader :filters
    alias filter filters
    attr_accessor :tmp_dir

    def Tree.new_with_document_struct(document_struct, include_paths = [])
      Tree.new(document_struct, nil, include_paths)
    end

    def initialize(document_struct, src_str = nil, include_paths = [])
      @src = src_str
      @document_struct = document_struct
      @include_paths = include_paths
      @filters = Hash.new()
      @tmp_dir = TMP_DIR
      @root = nil
    end
    
    def parse
      parser = RDParser.new
      src = @src.respond_to?(:to_a) ? @src.to_a : @src.split(/^/)
      set_root(parser.parse(src, self))
    end

    def set_root(element)
      raise ArgumentError, "#{element.class} can't be root." unless
	@document_struct.is_valid?(self, element)
      @root = element
      element.parent = self
    end
    alias root= set_root

    def make_root(&block)
      child = DocumentElement.new
      set_root(child)
      child.build(&block) if block_given?
      child
    end

    def check_valid
      each_element do |i|
	raise RuntimeError,
	  "mismatched document structure, #{i.parent} <-/- #{i}." unless
	  @document_struct.is_valid?(i.parent, i)
      end
      true
    end

    def accept(visitor)
      @root.accept(visitor)
    end
    
    def each_element(&block)
      return nil unless @root
      @root.each(&block)
    end
    alias each each_element

    def tree
      self
    end
    
    def Tree.new_from_rdo(*rdos) # rdos: IOs
      tree = Tree.new("", [], nil)
      tree_content = []
      rdos.each do |i|
	subtree = Marshal.load(i)
	tree_content.concat(subtree.root.blocks)
      end
      tree.root = DocumentElement.new(tree_content)
      tree
    end
  end
end
