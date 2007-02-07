#!/usr/bin/env ruby
#-*-ruby-*-
require "test/unit"

$:.unshift( "#{File.dirname(__FILE__)}/.." )
require "tdiary"
require "tdiary/wiki_style"

class WikiStyleTest < Test::Unit::TestCase
  def test_wiki_style
    # -------- wiki_style source
    source = <<-'EOF'
! subTitle
honbun

!! subTitleH4
honbun

    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>
<h4>subTitleH4</h4>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_wiki_style2
    # -------- wiki_style source
    source = <<-'EOF'
subTitle

honbun

honbun

    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></p>
<p>honbun</p>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_wiki_style3
    # -------- wiki_style source
    source = <<-'EOF'
subTitle

honbun

honbun

! subTitle

honbun

    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></p>
<p>honbun</p>
<p>honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>
honbun</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_wiki_style_plugin
    # -------- wiki_style source
    source = <<-'EOF'
! subTitle
{{plugin}}
{{plugin}}
aaa

{{plugin}}

a{{ho
ge}}b

{{ho
ge}}
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p><%=plugin
%>
<%=plugin
%>
aaa</p>
<p><%=plugin
%></p>
<p>a<%=ho
ge
%>b</p>
<p><%=ho
ge
%></p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
    EOF
    checkConversion(source, html)
  end

  def test_wiki_style_kw
    # -------- wiki_style source
    source = <<-'EOF'
! subTitle
[[aaa]]

[[aaa|bbb]]

[[aaa'bbb|ccc]]

[[aaa|aaa]]

[[aaa:鯖]]

[[aaa|bbb:ccc]]

[[aaa'bbb|bbb:ccc]]

[[鯖|http://ja.wikipedia.org/wiki/%E9%AF%96]]

http://ja.wikipedia.org/wiki/%E9%AF%96
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p><%=kw 'aaa', 'aaa'%></p>
<p><a href="bbb">aaa</a></p>
<p><a href="ccc">aaa'bbb</a></p>
<p><%=kw 'aaa', 'aaa'%></p>
<p><%=kw 'aaa:鯖'%></p>
<p><%=kw 'bbb:ccc', 'aaa'%></p>
<p><%=kw 'bbb:ccc', 'aaa\'bbb'%></p>
<p><a href="http://ja.wikipedia.org/wiki/%E9%AF%96">鯖</a></p>
<p><a href="http://ja.wikipedia.org/wiki/%E9%AF%96">http://ja.wikipedia.org/wiki/%E9%AF%96</a></p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
    EOF
    checkConversion(source, html)
  end

  def checkConversion(source, htmlExpected, opt = nil)
    opt ||= {}
    diary = TDiary::WikiDiary.new(Time.local(2003, 1, 1), "TITLE", "")
    diary.append(source)
    if opt[:preConvertHtml]
      opt[:preConvertHtml].call(diary)
    end
    htmlResult = diary.to_html({'anchor' => true})
    if htmlExpected == htmlResult
      assert(true)
    else
      $diffOutput ||= File.open("wiki_style_test.diff", "w")
      require "tempfile"
      files = [htmlExpected, htmlResult].collect { |content|
        tmpfile = Tempfile.new("wiki_style")
        tmpfile.write(content)
        tmpfile.flush
        tmpfile.path
      }
      $diffOutput.print(`diff -u #{files[0]} #{files[1]}`)
      assert(false, "(See wiki_style_test.diff)\n-- Expected\n#{htmlExpected}\n-- Result\n#{htmlResult}")
    end
  end
end #/WikiStyleTest
