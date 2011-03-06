# -*- coding: utf-8; -*-

require File.expand_path('../test_helper', __FILE__)
require 'misc/style/rd/rd_style'

class RdStyleTest < Test::Unit::TestCase
  def test_rd_style
    # -------- wiki_style source
    source = <<-'EOF'
= subTitle
honbun

== subTitleH4
honbun

    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ))%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>
<h4>subTitleH4</h4>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ))%>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_rd_style_plugin
    # -------- wiki_style source
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

    # -------- HTML
    html = <<-'EOF'
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
    checkConversion(source, html)
  end

  def checkConversion(source, html)
    diary = TDiary::RdDiary.new(Time::at( 1041346800 ), "TITLE", "")
    diary.append(source)
    htmlExpected = html
    htmlResult = diary.to_html({'anchor' => true})
    assert_diary(htmlExpected, htmlResult)
  end
end
