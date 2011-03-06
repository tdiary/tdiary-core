require 'rd/element'
require 'rd/list'
require 'rd/complex-list-item'
require 'rd/labeled-element'

module RD
  class DescList < List
    def accept(visitor)
      visitor.visit_DescList(self)
    end
  end
  
  class DescListItem < ListItem
    include ComplexListItem
    
    attr_reader :term
    attr_reader :description
    
    def initialize
      @term = nil
      @description = []
      @label = nil
    end

    def accept(visitor)
      visitor.visit_DescListItem(self)
    end

    class Term < Element
      include NonterminalElement
      include LabeledElement
      
      def initialize
	@content = []
      end

      def calculate_label
	ret = ""
	children.each do |i|
	  ret.concat(i.to_label)
	end
	ret
      end
      private :calculate_label

      def accept(visitor)
	visitor.visit_DescListItemTerm(self)
      end
      
      def children
	@content
      end
    end
  end # DescListItem
end # RD
