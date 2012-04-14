require 'rd/element'
require 'rd/list'
require 'rd/complex-list-item'
require 'rd/labeled-element'

module RD
  class MethodList < List
    def accept(visitor)
      visitor.visit_MethodList(self)
    end
  end
  
  class MethodListItem < ListItem
    include ComplexListItem
    
    attr_reader :term
    attr_reader :description
    
    def initialize
      @term = nil
      @description = []
    end
    
    def accept(visitor)
      visitor.visit_MethodListItem(self)
    end
    
    def children
      @description
    end

    class Term < Element
      include TerminalElement
      include LabeledElement
      
      attr_reader :content
      
      def initialize(content = "")
	@content = content
      end

      def each_element
	yield(self)
      end
      alias each each_element

      def accept(visitor)
	visitor.visit_MethodListItemTerm(self)
      end

     def calculate_label
	@content.sub(/\s*(?:\(|\{).*$/, "")
     end
     private :calculate_label
    end
  end
end # RD
