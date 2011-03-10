# -*- coding: utf-8; -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'tdiary'
require 'tdiary/tdiary_style'

describe TDiary::TdiaryDiary do
	before do
		@diary = TDiary::TdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe 'test_tdiary_style' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF

			@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div><div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html.chomp }
	end

	describe 'test_tdiary_style2' do
		before do
			source = <<-'EOF'
<<a href="http://example.com">subTitle</a>
<p>honbun</p>
			EOF

			@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "<a href=\"http://example.com\">subTitle</a>" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html.chomp }
	end

	describe 'test_tdiary_style_plugin' do
		before do
			source = <<-'EOF'
subTitle
<%= plugin %>
<%= plugin %>
aaa
<%= plugin %>
a<%=ho
ge%>b
<%=ho
ge%>
			EOF

			@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<%= plugin %>
<%= plugin %>
aaa
<%= plugin %>
a<%=ho
ge%>b
<%=ho
ge%><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html.chomp }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
