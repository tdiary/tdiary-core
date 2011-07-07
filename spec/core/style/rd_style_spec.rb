# -*- coding: utf-8; -*-
require 'spec_helper'

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
			it { @diary.to_html.should eq @html }
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
		it { @diary.to_html.should eq @html }
	end

	describe '#add_section' do
		before do
			source = <<-'EOF'
= subTitle
honbun

== subTitleH4
honbun

			EOF
			@diary.append(source)
			@diary.add_section('subTitle2', 'honbun')

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>
<h4>subTitleH4</h4>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe '#delete_section' do
		before do
			source = <<-'EOF'
= subTitle
honbun

= subTitle2
honbun

			EOF
			@diary.append(source)
			@diary.delete_section(1)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
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
			it { @diary.to_html.should eq @html }
		end
	end

	describe 'test_rd_on_error' do
		context 'link' do
			before do
				source = <<-'EOF'
((<tdiary|http://www.tdiary.org/>))
				EOF
				@diary.append(source)
				@exception_message = <<-'EOF'
RD syntax error: line 1:
...((<tdiary|http:/ / www.tdiary.org/>)) ...
                    ^
				EOF
			end
			it {
				lambda{ @diary.to_html }.should raise_error(SyntaxError){ |e|
					e.message.should eq @exception_message
				}
			}
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
