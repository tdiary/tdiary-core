=begin
= head-filter.rb
$Id: head-filter.rb,v 1.5 2003/10/30 12:12:33 rubikitch Exp rubikitch $
Copyright(c) 2003 Rubikitch
Licence: Ruby's License or GPL-2+
=end
module RD
  HEAD_FILTER = Filter.new(:target) do |inn, out|
    $Visitor.head = inn.to_s
    out.print " "
  end
end

$RC["filter"]["head"] = RD::HEAD_FILTER
