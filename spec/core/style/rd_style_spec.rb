# -*- coding: utf-8; -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'tdiary'
require 'misc/style/rd/rd_style'

describe TDiary::RdDiary do
	before do
		@diary = TDiary::RdDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe 'test_rd_style' do
		before do
			source = <<-'EOF'
= subTitle
honbun

== subTitleH4
honbun

			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>
<h4>subTitleH4</h4>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
			EOF
			@diary.append(source)
		end

		it { @diary.to_html({'anchor' => true}).should eq @html }
	end

	describe 'test_rd_style_plugin' do
		before do
			source = <<-'EOF'
= subTitle
((%plugin%))
((%plugin%))
aaa

((%plugin%))

a((%ho
ge%))b

((%ho
ge%))
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p><%=plugin %>
<%=plugin %>
aaa</p>
<p><%=plugin %></p>
<p>a<%=ho ge%>b</p>
<p><%=ho ge%></p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true}).should eq @html }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
