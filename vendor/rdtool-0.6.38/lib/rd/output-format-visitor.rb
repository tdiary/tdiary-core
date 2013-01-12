require 'rd/visitor'
require 'rd/rd-struct'
require 'rd/search-file'

module RD
  class OutputFormatVisitor < Visitor
    include SearchFile

    # must-have constants
    OUTPUT_SUFFIX = ""
    INCLUDE_SUFFIX = []

    attr_accessor :include_suffix
    attr_accessor :filename
    attr_accessor :input_filename

    def initialize
      super
      @include_suffix = self.class::INCLUDE_SUFFIX.clone
      @filename = nil
      @input_filename = "-"
    end

    def apply_to_Include(element)
      fname = search_file(element.filename, element.tree.include_paths,
			  @include_suffix)
      File.readlines(fname).join("") if fname
    end
  end 
end # RD
