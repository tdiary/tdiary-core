require 'rd/document-struct'
require 'rd/tree'
require 'rd/element'
require 'rd/block-element'
require 'rd/list'
require 'rd/desclist'
require 'rd/methodlist'
require 'rd/inline-element'

# definition of RD document structure.

module RD
  # interface. can be component of ListItem.
  module ListItemComposable
  end
  # interface. can be component of Headline and Reference.
  module LabelComposable
  end
  # interface. can include Inline
  module InlineIncludable
  end

  class DocumentStructure
    RD = DocumentStructure.new

    RD.define_relationship(Tree, DocumentElement)
    RD.define_relationship(DocumentElement, BlockElement)
    RD.define_relationship(Headline, LabelComposable)
    RD.define_relationship(TextBlock, InlineElement)
    RD.define_relationship(ItemList, ItemListItem)
    RD.define_relationship(EnumList, EnumListItem)
    RD.define_relationship(DescList, DescListItem)
    RD.define_relationship(MethodList, MethodListItem)
    RD.define_relationship(ListItem, ListItemComposable)
    RD.define_relationship(DescListItem, DescListItem::Term) 
    RD.define_relationship(DescListItem::Term, LabelComposable)
    RD.define_relationship(MethodListItem, MethodListItem::Term)   
    RD.define_relationship(InlineIncludable, InlineElement)
    RD.define_relationship(Reference, LabelComposable)
  end
  
  class TextBlock
    include ListItemComposable
  end
  class Verbatim
    include ListItemComposable
  end
  class ItemList
    include ListItemComposable
  end
  class EnumList
    include ListItemComposable
  end
  class DescList
    include ListItemComposable
  end
  class StringElement
    include LabelComposable
  end
  class Emphasis
    include LabelComposable
    include InlineIncludable
  end
  class Code
    include LabelComposable
    include InlineIncludable
  end
  class Var
    include LabelComposable
    include InlineIncludable
  end
  class Keyboard
    include LabelComposable
    include InlineIncludable
  end
  class Index
    include LabelComposable
    include InlineIncludable
  end
  class Footnote
    include InlineIncludable
  end
  class Verb
    include LabelComposable
  end
end
