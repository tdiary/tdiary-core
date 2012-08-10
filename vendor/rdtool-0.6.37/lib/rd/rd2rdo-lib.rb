=begin
= rd2rdo-lib.rb
Format lib to dump tree objects.
=end

require "rd/rdvisitor"

module RD
  class RD2RDOVisitor < RDVisitor
    OUTPUT_SUFFIX = "rdo"
    INCLUDE_SUFFIX = []
    
    def visit(tree)
      Marshal.dump(tree)
    end
  end
end

$Visitor_Class = RD::RD2RDOVisitor
