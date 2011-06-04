# -*- coding: utf-8; -*-
require 'spec_helper'

require 'tdiary'
require 'misc/style/emptdiary/emptdiary_style'

describe TDiary::EmptdiaryDiary do
	before do
		@diary = TDiary::EmptdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe '#append' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF
			@diary.append(source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
</div><div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
				EOF
			end
			it { @diary.to_html.should eq @html.chomp }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></H3>
<p>honbun</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></H3>
<p>honbun</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
				EOF
			end
			it { @diary.to_html({}, :CHTML).should eq @html }
		end
	end

	describe '#replace' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF
			@diary.append(source)

			replaced = <<-'EOF'
replaceTitle
<p>replace</p>

replaceTitle2
<p>replace</p>

			EOF
			@diary.replace(Time::at( 1041346800 ), "TITLE", replaced)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "replaceTitle" ) %></h3>
<p>replace</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
</div><div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "replaceTitle2" ) %></h3>
<p>replace</p><%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html.chomp }
	end

	describe 'test_emptdiary_style_plugin' do
		before do
			source = <<-'EOF'
sectionTitle
<p>body</p>
<%=pre <<'_PRE'
#include <stdio.h>

/* comment */
int
main (int argc, char *argv[])
{
  puts ("Hello world.");
}
_PRE
%>
			EOF
			@diary.append(source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "sectionTitle" ) %></h3>
<p>body</p>
<%=pre <<'_PRE'
#include <stdio.h>

/* comment */
int
main (int argc, char *argv[])
{
  puts ("Hello world.");
}
_PRE
%><%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
				EOF
			end
			it { @diary.to_html.should eq @html.chomp }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "sectionTitle" ) %></H3>
<p>body</p>
<%=pre <<'_PRE'
#include <stdio.h>

/* comment */
int
main (int argc, char *argv[])
{
  puts ("Hello world.");
}
_PRE
%><%=section_leave_proc( Time::at( 1041346800 ) )%>
				EOF
			end
			it { @diary.to_html({}, :CHTML).should eq @html }
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
