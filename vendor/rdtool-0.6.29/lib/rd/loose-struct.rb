require 'rd/document-struct'
require 'rd/element'
require 'rd/tree'

module RD
  class DocumentStructure
    LOOSE = DocumentStructure.new
    LOOSE.define_relationship(NonterminalElement, Element)
    LOOSE.define_relationship(Tree, DocumentElement)
  end
end
