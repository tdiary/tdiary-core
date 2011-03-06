require 'rd/output-format-visitor'
require 'rd/reference-resolver'
require 'rd/rbl-file'
require 'forwardable'

module RD
  # for Backward compatibility
  class RDVisitor < OutputFormatVisitor
    extend Forwardable

    def apply_to_DescListItemTerm(element, contents)
      contents
    end

    def apply_to_MethodListItemTerm(element)
      apply_to_String(element.content)
    end
    
    def_delegator(:@reference_resolver, :labels, :__labels__)
    def_delegator(:@reference_resolver, :label_prefix, :__label_prefix__)
    def_delegator(:@reference_resolver, :rbl_suite)

    def prepare_labels(tree, prefix = "label:")
      @reference_resolver = ReferenceResolver.new(tree, prefix)
    end

    def_delegator(:@reference_resolver, :refer)
    def_delegator(:@reference_resolver, :get_anchor)
    def_delegator(:@reference_resolver, :make_rbl_file)

    def refer_external(label)
      label = @reference_resolver.refer_external_file(label)
      return nil unless label
      label[1]
    end
  end

  module AutoLabel
    def parse_rmi(src)
      labels = {}
      $method_index = []
      eval(src)
      $method_index.each do |c, k, m, f, l|
	labels[c + k + m] = l
      end
      labels
    end
    private :parse_rmi
  end # AutoLabel

=begin
== module RD::MethodParse
this module provide several functions for MehotList.
=end
  
  module MethodParse

    def analize_method(method)
      klass = nil
      args = nil
      kind = nil
      if /[^{(\s]+/ =~ method
	method = $&
	args = $'                   # '
      end

      if /^(.*)(#|::|\.)/ =~ method
	klass = $1
	kind = str2kind($2)
	method = $'                 # '
      end
      
      if klass == "function" and kind == :instance_method
	kind = :function
      end
      
      [klass, kind, method, args]
    end
    module_function :analize_method

    def str2kind(str)
      case str
      when '#'
	:instance_method
      when '.'
	:class_method
      when '::'
	:constant
      end
    end
    module_function :str2kind
            
    def kind2str(int)
      case int
      when :instance_method, :function
	'#'
      when :class_method
	'.'
      when :constant
	'::'
      end
    end
    module_function :kind2str

    KIND2NUM = {:constant => 0, :class_method => 1, :instance_method => 2, :function => 2}
    def kind2num(str)
      KIND2NUM[str]
    end
    module_function :kind2num
       
    def make_mindex_label(element)
      klass, kind, method = analize_method(element.label)
      case kind
      when :class_method
	klass + "_S_" + tr_method(method)
      when :instance_method
	klass + "_" + tr_method(method)
      when :constant
	klass + "_" + method
      when :function
	"function_" + tr_method(method)
      else
	element.label
      end
    end
    module_function :make_mindex_label

    def tr_method(method)
      case method
      when "[]"
	"ref_"
      when "[]="
	"set_"
      when "+"
	"plus_"
      when "+@"
	"uplus_"
      when "-"
	"minus_"
      when "-@"
	"uminus_"
      when "*"
	"mul_"
      when "/"
	"div_"
      when "%"
        "mod_"
      when "**"
	"power_"
      when "~"
	"inv_"
      when "=="
	"eq_"
      when "==="
	"eqq_"
      when "=~"
	"match_"
      when "&"
	"and_"
      when "|"
	"or_"
      when "<<"
	"lshift_"
      when ">>"
	"rshift_"
      when "<=>"
	"cmp_"
      when "<"
	"lt_"
      when "<="
	"le_"
      when ">"
	"gt_"
      when ">="
	"ge_"
      when "^"
	"xor_"
      when "`"
	"backquote_"
      when /!$/
	$` + "_bang"     # `
      when /\?$/
	$` + "_p"        # `
      when /=$/
	$` + "_eq"       # `
      else
	method
      end
    end
    module_function :tr_method
    
    def make_method_index(tree)
      indexes = []
      tree.each do |i|
	if i.is_a?(MethodListItem)
	  klass, kind, method, args = analize_method(i.term.content)
	  indexes.push([klass, kind2num(kind), method, kind]) if kind
	end
      end
      indexes.uniq!
      indexes.sort.each {|i| i[1] = i.pop}
    end
    module_function :make_method_index
	  
  end # MethodParse
end # RD

=begin
== script info.
 abstruct class for visitor of RDTree.
 $Id: rdvisitor.rb,v 1.46 2003/02/18 16:20:25 tosh Exp $

=end

