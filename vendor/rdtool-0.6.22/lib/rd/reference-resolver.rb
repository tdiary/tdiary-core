require 'rd/rbl-suite'
require 'rd/labeled-element'

require 'forwardable'

module RD
  class ReferenceResolver
    extend Forwardable
    include Enumerable
    
    attr_reader :labels
    attr_reader :label_prefix
    attr_reader :rbl_suite
    
    def initialize(tree, prefix = "label:")
      init_labels(tree)
      @label_prefix = prefix
      @rbl_suite = RBLSuite.new(tree.include_path)
    end

    def init_labels(tree)
      @labels = {}
      ary = (tree.find_all do |i|
	       i.is_a? LabeledElement
	     end)
      num = 0
      ary.each do |i|
	push_to_labels(i.to_label, [i, num])
	num += 1
      end
    end
    private :init_labels

    def push_to_labels(key, value)
      if labels[key]
	labels[key].push(value)
      else
	labels[key] = [value]
      end
    end
    private :push_to_labels

    def each_label
      tmp = []
      labels.each_value do |i|
	i.each do |j|
	  tmp.push(j)
	end
      end
      tmp.sort{|i,j| i[1] <=> j[1]}.each do |i|
	yield(i[0])
      end
    end
    alias each each_label

    def referent_of_label(label)
      label = label.label if label.is_a? Reference
      if label.filename
	refer_external_file(label)
      else
	anchor = refer(label)
	return nil unless anchor
	[nil, anchor]
      end
    end

    def refer(label)
      matched = labels[label2str(label)]
      return nil unless matched
      num2anchor(matched[0][1])
    end

    def refer_element(label)
      labels.fetch(label2str(label), []).collect{|i| i[0] }
    end

    def refer_external_file(label)
      label = label.label if label.is_a? Reference
      rbl_suite.refer(label.element_label, label.filename)
    end

    def get_label_num(element)
      entry = labels[element.to_label].find{|i| i[0] == element }
      return nil unless entry
      entry[1]
    end

    def get_anchor(element)
      if num = get_label_num(element)
	num2anchor(num)
      end
    end

    def num2anchor(num)
      label_prefix + num.to_s
    end
    private :num2anchor
    
    def label2str(label)
      case label
      when String
	label
      when Element, Reference::RDLabel
	label.to_label
      else
	raise ArgumentError, "can't extract Label from #{label}."
      end
    end

    def make_rbl_file(filename)
      RBLFile.create_rbl_file(filename, self)
    end
  end
end
