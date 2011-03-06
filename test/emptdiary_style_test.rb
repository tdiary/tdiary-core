# -*- coding: utf-8; -*-

require File.expand_path('../test_helper', __FILE__)
require 'misc/style/emptdiary/emptdiary_style'

class EmptdiaryStyleTest < Test::Unit::TestCase
  def test_emptdiary_style
    # -------- tdiary_style source
    source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
    EOF

    # -------- HTML
    html = <<-'EOF'
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
    checkConversion(source, html)
  end

  def test_emptdiary_style_plugin
    # -------- wiki_style source
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

    # -------- HTML
    html = <<-'EOF'
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
    checkConversion(source, html)
  end

  def checkConversion(source, html)
    diary = TDiary::EmptdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
    diary.append(source)
    htmlExpected = html.chomp
    htmlResult = diary.to_html({'anchor' => true})
    assert_diary(htmlExpected, htmlResult)
  end
end
