require 'rd/block-element'
require 'rd/element'

module RD
  class List < BlockElement
    include NonterminalElement
    attr_reader :items
    
    def initialize
      @items = []
    end
    
    alias each_item each_child
  
    def children
      @items
    end
  end
  
  class ListItem < BlockElement
    include NonterminalElement
    
    attr_reader :content
    
    def initialize
      @content = []
    end
    
    alias each_block each_child
    
    def children
      @content
    end
  end
  
  class ItemList < List
    def accept(visitor)
      visitor.visit_ItemList(self)
    end
  end
  class ItemListItem < ListItem
    def accept(visitor)
      visitor.visit_ItemListItem(self)
    end
  end
  
  class EnumList < List
    def accept(visitor)
      visitor.visit_EnumList(self)
    end
  end
  class EnumListItem < ListItem
    def accept(visitor)
      visitor.visit_EnumListItem(self)
    end
  end
end # RD
