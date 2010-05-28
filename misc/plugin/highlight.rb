#
# highlight.rb: Highlighting the element jumped from other pages.
#
# Copyright (C) 2003 by Ryuji SAKAI
# Copyright (C) 2003 by Kazuhiro NISHIYAMA
# You can redistribute it and/or modify it under GPL2.
#
if @mode == 'day' and not bot? then
	add_footer_proc do
		<<-SCRIPT
			<script type="text/javascript"><!--
			var highlightElem = null;
			var saveClass = null;
	
			function highlightElement(name) {
				if (highlightElem) {
					highlightElem.className = saveClass;
					highlightElem = null;
				}
	
				highlightElem = getHighlightElement(name);
				if (!highlightElem) return;
			
				saveClass = highlightElem.className;
				highlightElem.className = "highlight";

				if (highlightElem.tagName.toLowerCase() == 'h3') {
					var diary_title = "#{(@conf.html_title.gsub(/\\/, '\\\\\\') || '').gsub(/&/, '&amp;').gsub(/"/, '&quot;').gsub(/>/, '&gt;').gsub(/</, '&lt;')}(#{@date.strftime('%Y-%m-%d')})";
					var sanchor_length = "#{apply_plugin( @conf.section_anchor ).gsub(/<[^>]+?>/, '').gsub(/\"/, '\"')}".length;
					var section_title = highlightElem.innerHTML.replace(/<[^>]+?>/g, '').substr(sanchor_length + 1).replace(/^[ ]*/, '').replace(/[ ]*$/, '');;
					document.title = (section_title + ' - ' + diary_title).replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&amp;/g, '&');
				}
			}
					
			function getHighlightElement(name) {
				for (var i=0; i<document.anchors.length; ++i) {
					var anchor = document.anchors[i];
					if (anchor.name == name) {
						var elem;
						if (anchor.parentElement) {
							elem = anchor.parentElement;
						} else if (anchor.parentNode) {
							elem = anchor.parentNode;
						}
						return elem;
					}
				}
				return null;
			}
			
			if (document.location.hash) {
				highlightElement(document.location.hash.substr(1));
			}
			
			hereURL = document.location.href.split(/\#/)[0];
			for (var i=0; i<document.links.length; ++i) {
				if (hereURL == document.links[i].href.split(/\#[pc]/)[0]) {
					document.links[i].onclick = handleLinkClick;
				}
			}
			
			function handleLinkClick() {
				highlightElement(this.hash.substr(1));
			}
			// --></script>
		SCRIPT
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vi: ts=3 sw=3
