
module RD
  # interface
  module LabeledElement
    def to_label
      @label ||= calculate_label
    end
    alias label to_label
    
    def calculate_label
      raise "[BUG] must override."
    end
  end
end
