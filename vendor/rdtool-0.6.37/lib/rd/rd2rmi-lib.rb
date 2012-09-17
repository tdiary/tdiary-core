=begin
= rd2rmi-lib.rb
library to output RMI.
=end
require "rd/rdvisitor"

module RD
  class RD2RMIVisitor < RDVisitor
    include AutoLabel
    include MethodParse

    OUTPUT_SUFFIX = "rmi"
    INCLUDE_SUFFIX = ["rmi"]
    
    def visit(tree)
      ret = ""

      prepare_labels(tree)
      
      index = make_method_index(tree)
      index.each do |i|
	i[1] = kind2str(i[1])
	i[3] = @filename
	i[4] = refer(i[0]+i[1]+i[2])
	ret << "$method_index.push(#{i.inspect})\n"
      end
      ret
    end
  end # class RD2RMIVisitor
end # module RD

$Visitor_Class = RD::RD2RMIVisitor
