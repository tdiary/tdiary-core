
module RD
  module ParserUtility
    def add_children_to_element(parent, *children)
#      parent.add_children_under_document_struct(children,
#						tree.document_struct)
      parent.add_children_without_document_struct(children)
    end

    def tree
      raise NotImplementedError, "Subclass Responsibility"
    end
  end
end
