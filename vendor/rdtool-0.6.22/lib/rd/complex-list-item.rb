

module RD
  # abstruct class for ListItem which have term part additionaly. 
  # (i.e. DescListItem and MethodListItem)
  module ComplexListItem
    def set_term(term)
      set_term_under_document_struct(term, tree.document_struct)
    end
    alias term= set_term

    def set_term_under_document_struct(term, document_struct)
      raise ArgumentError unless document_struct.is_valid?(self, term)
      assign_term(term)
    end

    def set_term_without_document_struct(term)
      assign_term(term)
    end

    def assign_term(term)
      @term = term
      term.parent = self
    end
    
    def make_term(*args_of_new, &block)
      child = self.class::Term.new(*args_of_new)
      set_term(child)
      child.build(&block) if block_given?
      child
    end

    def each_element(&block)
      yield(self)
      @term.each_element(&block)
      @description.each do |i|
	i.each_element(&block)
      end
    end
    alias each each_element
    
    def each_block_in_description
      @description.each do |i|
	yield(i)
      end
    end
    alias each_block each_block_in_description

    def children
      @description
    end

    def to_label
      @term.to_label
    end
    alias label to_label

    def inspect
      t = indent2(term.inspect) if term
      c  = children.collect{|i| indent2(i.inspect)}.join("\n")
      "<#{self.class.name}>" + (term ? "\n" : "") + t.to_s +
	(c.empty? ? "" : "\n") + c
    end
  end # ComplexListItem
end # RD
