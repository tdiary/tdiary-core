require "rd/element"
require "rd/document-struct"
require "rd/visitor"

module RD
  class DummyElement < Element
    attr_accessor :parent

    def children
      []
    end
    
    def each_element
      yield(self)
    end

    def accept(visitor)
      "dummy"
    end
    
    def to_label
      " label "
    end
  end
  
  DummyStruct = DocumentStructure.new
end

class DummyVisitor < RD::Visitor
  def method_missing(method, *args)
    [method.to_s, args]
  end
end
