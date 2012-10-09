desc "generate document files"
task :doc do
	require 'redcarpet'
	require 'pathname'
	FileList['doc/*.md'].each do |md|
		target = Pathname.new(md)
		header = <<-HEADER
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja-JP">
<head>
<title>#{target.basename('.md')}</title>
<link href="doc.css" media="screen" rel="stylesheet" type="text/css" />
</head>
<body>
HEADER
		footer = <<-FOOTER
</body>
</html>
FOOTER
		html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true).render(File.open(md).read)
		open(target.sub(/\.md\z/, '.html'), 'w') {|f| f.write(header + html + footer)}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
