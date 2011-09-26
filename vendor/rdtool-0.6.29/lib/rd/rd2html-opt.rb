=begin
= rd2html-opt.rb
sub-OptionParser for rd2html-lib.rb.
=end
require "optparse"

q = ARGV.options

q.on_tail("rd2html-lib options:")


#q.on_tail("--use-numbering-anchor",
#	  "use number for anchor name (old style)") do
#  $Visitor.use_old_anchor = true
#end

q.on_tail("--output-rbl",
	  "output external Label file") do
  $Visitor.output_rbl = true
end

q.on_tail("--with-css=FILE",
	  String,
	  "use FILE as CSS of output HTML") do |i|
  $Visitor.css = i
end

q.on_tail("--html-charset=CHARSET",
	  String,
	  "indicate CHARSET as charset(char encoding)") do |i|
  $Visitor.charset = i
end

q.on_tail("--html-lang=LANG",
	  String,
	  "indicate LANG as lang attribute of html") do |i|
  $Visitor.lang = i
end
  
q.on_tail("--html-title=TITLE",
	  String,
	  "content of TITLE element of HTML") do |i|
  $Visitor.title = i
end

q.on_tail("--html-link-rel=REL",
	  String,
	  "add forward LINK element.(\"<rel>:<href>\")") do |i|
  if /(\w+):(.+)/ =~ i
    $Visitor.html_link_rel[$1] = $2
  else
    # warning
  end
end

q.on_tail("--html-link-rev=REV",
	  String,
	  "add reverse LINK element.(\"<rev>:<href>\")") do |i|
  if /(\w+):(.+)/ =~ i
    $Visitor.html_link_rev[$1] = $2
  else
    # warning
  end
end



