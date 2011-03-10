# -*- coding: utf-8; -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'tdiary'
require 'misc/style/emptdiary/emptdiary_style'

describe TDiary::EmptdiaryDiary do
	before do
		@diary = TDiary::EmptdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe 'test_emptdiary_style' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF

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
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true}).should eq @html.chomp }
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
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true}).should eq @html.chomp }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
