
module RD
  # DocumentStructure defines and restricts structure of document tree.
  # it consists of ElementRelationship
  class DocumentStructure
    def initialize
      @relationships = []
    end
    
    def add_relationships(*relations)
      @relationships += relations
    end

    def define_relationship(parent, child)
      add_relationships(ElementRelationship.new(parent, child))
    end

    def each_relationship
      @relationships.each do |i|
	yield(i)
      end
    end

    def is_valid?(parent, child)
      each_relationship do |i|
	return true if i.match?(parent, child)
      end
      false
    end
  end

  # ElementRelationship is knowledge about parent-children relationship
  # between Elements.
  class ElementRelationship
    attr_reader(:parent, :child)

    def initialize(parent, child)
      @parent = parent
      @child = child
    end

    def match?(parent, child)
      parent.is_a? @parent and child.is_a? @child
    end
  end
end
