# -*- coding: utf-8; -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'tdiary'
require 'misc/style/rd/rd_style'

describe TDiary::RdDiary do
	before do
		@diary = TDiary::RdDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe '#append' do
		before do
			source = <<-'EOF'
= subTitle
honbun

== subTitleH4
honbun

			EOF
			@diary.append(source)
		end

		context 'HTML' do
			before do
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
			end
			it { @diary.to_html({'anchor' => true}).should eq @html }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%=section_enter_proc( Time::at( 1041346800 ))%>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></H3>
<p>honbun</p>
<H4>subTitleH4</H4>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
				EOF
			end
			it { @diary.to_html({'anchor' => true}, :CHTML).should eq @html }
		end
	end

	describe '#replace' do
		before do
			source = <<-'EOF'
= subTitle
honbun

== subTitleH4
honbun

			EOF
			@diary.append(source)

			replaced = <<-'EOF'
= replaceTitle
replace

== replaceTitleH4
replace

			EOF
			@diary.replace(Time::at( 1041346800 ), "TITLE", replaced)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "replaceTitle" ) %></h3>
<p>replace</p>
<h4>replaceTitleH4</h4>
<p>replace</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
			EOF
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
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
			@diary.append(source)
		end

		context 'HTML' do
			before do
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
			end
			it { @diary.to_html({'anchor' => true}).should eq @html }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%=section_enter_proc( Time::at( 1041346800 ))%>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></H3>
<p><%=plugin %>
<%=plugin %>
aaa</p>
<p><%=plugin %></p>
<p>a<%=ho ge%>b</p>
<p><%=ho ge%></p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
				EOF
			end
			it { @diary.to_html({'anchor' => true}, :CHTML).should eq @html }
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
