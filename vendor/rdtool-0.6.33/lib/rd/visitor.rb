require "rd/version"

module RD
  class Visitor
    SYSTEM_NAME = "RDtool Framework -- Visitor"
    SYSTEM_VERSION = "$Version: "+RD::VERSION+"$"
    VERSION = Version.new_from_version_string(SYSTEM_NAME, SYSTEM_VERSION)

    def Visitor.version
      VERSION
    end
    
    def visit(tree)
      tree.accept(self)
    end

    def visit_children(element)
      ret = []
      element.each_child do |i|
	ret.push(i.accept(self))
      end
      ret
    end

    def Visitor.define_visit_Nonterminal(element_type)
      eval <<-END_OF_EVAL
      def visit_#{element_type.id2name}(element)
	apply_to_#{element_type.id2name}(element, visit_children(element))
      end
      END_OF_EVAL
    end

    def Visitor.define_visit_Terminal(element_type)
      eval <<-END_OF_EVAL
      def visit_#{element_type.id2name}(element)
	apply_to_#{element_type.id2name}(element)
      end
      END_OF_EVAL
    end

    define_visit_Terminal(:Include)
    define_visit_Terminal(:Verbatim)
    define_visit_Terminal(:MethodListItemTerm)

    define_visit_Nonterminal(:DocumentElement)
    define_visit_Nonterminal(:Headline)
    define_visit_Nonterminal(:TextBlock)
    define_visit_Nonterminal(:ItemList)
    define_visit_Nonterminal(:EnumList)
    define_visit_Nonterminal(:DescList)
    define_visit_Nonterminal(:MethodList)
    define_visit_Nonterminal(:ItemListItem)
    define_visit_Nonterminal(:EnumListItem)
    
    def visit_DescListItem(element)
      term = element.term.accept(self)
      apply_to_DescListItem(element, term, visit_children(element))
    end

    define_visit_Nonterminal(:DescListItemTerm)

    def visit_MethodListItem(element)
      term = element.term.accept(self)
      apply_to_MethodListItem(element, term, visit_children(element))
    end

    define_visit_Terminal(:StringElement)
    define_visit_Terminal(:Verb)

    define_visit_Nonterminal(:Emphasis)
    define_visit_Nonterminal(:Code)
    define_visit_Nonterminal(:Var)
    define_visit_Nonterminal(:Keyboard)
    define_visit_Nonterminal(:Index)
    define_visit_Nonterminal(:Footnote)

    def visit_Reference(element)
      children = visit_children(element)
      begin
	element.result_of_apply_method_of(self, children)
      rescue NameError
	apply_to_Reference(element, children)
      end
    end
  end 
end 
