require 'rd/element'

module RD
  
  # Inline-level Element of document tree
  class InlineElement < Element
  end

  # abstruct class.
  class TerminalInline < InlineElement
    include TerminalElement

    attr_accessor :content

    def initialize(content)
      super()
      @content = content
    end
  end
  
  # abstract class.
  class NonterminalInline < InlineElement
    include NonterminalElement

    attr_reader :content
    
    def initialize
      super()
      @content = []
    end

    def children
      @content
    end

    def to_label
      ret = ""
      children.each do |i|
	ret << i.to_label
      end
      ret.strip
    end
  end # NonterminalInline
  
  class StringElement < TerminalInline
    def accept(visitor)
      visitor.visit_StringElement(self)
    end

    def to_label
      @content
    end
  end
  
  class Verb < TerminalInline
    def accept(visitor)
      visitor.visit_Verb(self)
    end

    def to_label
      @content.strip
    end
  end
  
  class Emphasis < NonterminalInline
    def accept(visitor)
      visitor.visit_Emphasis(self)
    end
  end
  
  class Code < NonterminalInline
    def accept(visitor)
      visitor.visit_Code(self)
    end
  end
  
  class Var < NonterminalInline
    def accept(visitor)
      visitor.visit_Var(self)
    end
  end
  
  class Keyboard < NonterminalInline
    def accept(visitor)
      visitor.visit_Keyboard(self)
    end
  end
  
  class Index < NonterminalInline
    def accept(visitor)
      visitor.visit_Index(self)
    end
  end

  class Footnote < NonterminalInline
    def accept(visitor)
      visitor.visit_Footnote(self)
    end
  end

  class Reference < NonterminalInline
    attr_accessor :label   # Reference::Label
    alias set_label label=

    def initialize(label)
      super()
      @content = []
      @label = label.renew_label
    end

    def Reference.new_from_label(label)
      ref = Reference.new(label)
      ref.add_children(label.to_reference_content)
      return ref
    end

    def Reference.new_from_label_under_document_struct(label, struct)
      ref = Reference.new(label)
      ref.add_children_under_document_struct(label.to_reference_content,
					     struct)
      return ref
    end

    def Reference.new_from_label_without_document_struct(label)
      ref = Reference.new(label)
      ref.add_children_without_document_struct(label.to_reference_content)
      return ref
    end
    
    def accept(visitor)
      visitor.visit_Reference(self)
    end

    def result_of_apply_method_of(visitor, children)
      label.result_of_apply_method_of(visitor, self, children)
    end
    
    def to_label
      @label.to_label
    end

    # abstruct class. Label for Reference 
    class Label
      def extract_label
	raise NotImplementedError, "[BUG] must be overridden."
      end

      def to_reference_content
	raise NotImplementedError, "[BUG] must be overridden."
      end

      def result_of_apply_method_of(visitor)
	raise NotImplementedError, "[BUG] must be overridden."
      end
    end
  
    class URL < Label
      attr_accessor :url
      
      def initialize(url_str)
	@url = url_str
      end
      
      def to_label
	""
      end

      def result_of_apply_method_of(visitor, reference, children)
	visitor.apply_to_Reference_with_URL(reference, children)
      end

      def to_reference_content
	[StringElement.new("<URL:#{self.url}>")]
      end

      def renew_label
	self
      end
    end # URL

    class RDLabel < Label
      attr_accessor :element_label
      attr_accessor :filename

      def initialize(element_label, filename = nil)
	@element_label = element_label
	@filename = filename
      end

      def result_of_apply_method_of(visitor, reference, children)
	visitor.apply_to_Reference_with_RDLabel(reference, children)
      end

      def to_reference_content
	[]
      end

      def renew_label
	self
      end
      
      alias to_label element_label
    end # RDLabel

    # for initialization. Parameter Object(?)
    class TemporaryLabel < Label
      attr_accessor :element_label
      attr_accessor :filename

      def initialize(element_label = [], filename = nil)
	@element_label = element_label
	@filename = filename
      end

      def to_reference_content
	self.element_label
      end

      def renew_label
	RDLabel.new(extract_label(self.element_label), self.filename)
      end

      def extract_label(elements)
	ret = ""
	elements.each do |i|
	  ret << i.to_label
	end
	ret.strip
      end
      private :extract_label
    end
  end # Reference
end
