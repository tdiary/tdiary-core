
module RD

  # abstruct class of node of document tree
  class Element
    include Enumerable
    
    attr_accessor :parent

    def initialize
      @parent = nil
    end
    
    def tree
      raise RuntimeError, "#{self} doesn't have a parent." unless @parent
      @parent.tree
    end

    def inspect
      c  = children.collect{|i| indent2(i.inspect)}.join("\n")
      "<#{self.class.name}>" + (c.empty? ? "" : "\n") + c
    end
  end # Element

  # element which don't have children.
  module TerminalElement
    def children
      []
    end

    def each_element
      yield(self)
    end
    alias each each_element
  end

  # element which have children.
  module NonterminalElement
    def initialize(*arg)
      @temporary_document_structure = nil
      super
    end

    def children
      raise NotImplimentedError, "need #{self}#children."
    end

    def each_child
      children.each do |i|
	yield(i)
      end
    end

    def each_element(&block)
      yield(self)
      children.each do |i|
	i.each_element(&block)
      end
    end
    alias each each_element
    
    def add_child(child)
      add_child_under_document_struct(child, tree.document_struct)
    end

    def add_child_under_document_struct(child, document_struct)
      if document_struct.is_valid?(self, child)
	push_to_children(child)
      else
	raise ArgumentError,
	  "mismatched document structure, #{self} <-/- #{child}."
      end
      return self
    end

    def add_children(children)
      add_children_under_document_struct(children, tree.document_struct)
    end

    def add_children_under_document_struct(children, document_struct)
      children.each do |i|
	add_child_under_document_struct(i, document_struct)
      end
      return self
    end

    def add_children_without_document_struct(new_children)
      new_children.each do |i|
	push_to_children(i)
      end
      return self
    end

    def push_to_children(child)
      children.push(child)
      child.parent = self
    end

    attr_accessor :temporary_document_structure

    def build(document_struct = tree.document_struct, &block)
      under_temporary_document_structure(document_struct) do
	self.instance_eval(&block)
      end
      self
    end

    def make_child(child_class, *args_of_new, &block)
      child = child_class.new(*args_of_new)
      if self.temporary_document_structure
	self.add_child_under_document_struct(child,
					     self.temporary_document_structure)
	child.build(self.temporary_document_structure, &block) if block_given?
      else
	self.add_child(child)
	child.build(&block) if block_given?
      end
      child
    end
    alias new make_child
    private :new
    # NonterminalElement#new, not NonterminalElement.new

    def under_temporary_document_structure(document_struct)
      begin
	self.temporary_document_structure = document_struct
	yield
      ensure
	self.temporary_document_structure = nil
      end
    end

    def indent2(str)
      buf = ''
      str.each_line{|i| buf << "  " << i }
      buf
    end
    private :indent2
  end

  # root node of document tree
  class DocumentElement < Element
    include NonterminalElement
    attr_reader :blocks
    
    def initialize()
      @blocks = []
    end

    def accept(visitor)
      visitor.visit_DocumentElement(self)
    end

    alias each_block each_child
    
    def children
      @blocks
    end
  end
end
