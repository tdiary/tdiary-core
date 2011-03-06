# -*- coding: utf-8; -*-

require File.expand_path('../test_helper', __FILE__)
require 'tdiary/tdiary_style'

class TDiaryStyleTest < Test::Unit::TestCase
  def test_tdiary_style
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
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div><div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_tdiary_style2
    # -------- tdiary_style source
    source = <<-'EOF'
<<a href="http://example.com">subTitle</a>
<p>honbun</p>
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "<a href=\"http://example.com\">subTitle</a>" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_tdiary_style_plugin
    # -------- tdiary_style source
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

    # -------- HTML
    html = <<-'EOF'
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
    checkConversion(source, html)
  end

  def checkConversion(source, html)
    opt ||= {}
    diary = TDiary::TdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
    diary.append(source)
    htmlExpected = html.chomp
    htmlResult = diary.to_html({'anchor' => true})
    assert_diary(htmlExpected, htmlResult)
  end
end #/TDiaryStyleTest
