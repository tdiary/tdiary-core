# -*- coding: utf-8; -*-

require "test/unit"

$:.unshift( "#{File.dirname(__FILE__)}/.." )
require "tdiary"
require "tdiary/tdiary_style"

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

  def checkConversion(source, html, opt = nil)
    opt ||= {}
    diary = TDiary::TdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
    diary.append(source)
    if opt[:preConvertHtml]
      opt[:preConvertHtml].call(diary)
    end
    htmlExpected = html.chomp
    htmlResult = diary.to_html({'anchor' => true})
    if htmlExpected == htmlResult
      assert(true)
    else
      $diffOutput ||= File.open("tdiary_style_test.diff", "w")
      require "tempfile"
      files = [htmlExpected, htmlResult].collect { |content|
        tmpfile = Tempfile.new("tdiary_style")
        tmpfile.write(content)
        tmpfile.flush
        tmpfile.path
      }
      $diffOutput.print(`diff -u #{files[0]} #{files[1]}`)
      assert(false, "(See tdiary_style_test.diff)\n-- Expected\n#{htmlExpected}\n-- Result\n#{htmlResult}")
    end
  end
end #/TDiaryStyleTest
