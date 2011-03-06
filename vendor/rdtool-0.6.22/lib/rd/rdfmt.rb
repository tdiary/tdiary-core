
require 'rd/tree'
require 'rd/rd-struct'

module RD
  # for backward-compatibility.
  class RDTree < Tree
    def initialize(src_str, include_paths = [], do_parse = true)
      super(DocumentStructure::RD, src_str, include_paths)
      parse() if do_parse
    end
  end

  RDElement = Element
end
