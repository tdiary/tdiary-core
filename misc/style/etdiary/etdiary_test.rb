#!/usr/bin/env ruby
#-*-ruby-*-
require "test/unit"

thisdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(thisdir)
$LOAD_PATH.unshift("#{thisdir}/../../..")

require "tdiary"
require "etdiary_style"

class EtdiaryTest < Test::Unit::TestCase
  def test_etdiary
    # -------- etDiary source
    source = <<-'EOF'
hogehoge
fugafuga

fugahoge
hogera

<<subTitle>>
honbun

<<<>subTitleH4>>
honbun

<h4>notParagraph</h4>

<div>
Content of block element with blank line.

<blockquote>
hogehoge
</blockquote>
</div>

 <b>Paragraph</b> begin with tag.

<pre>
In <pre>, < and > are automatically escaped.
</pre>

<<>>
Section without title and anchor.

<<<>>>
Section without title.

    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<p>
hogehoge
fugafuga
</p>
<p>
fugahoge
hogera
</p>
</div>

<div class="section">
<h3>subTitle</h3>
<p>
honbun
</p>
<h4>subTitleH4:</h4>
<p>
honbun
</p>
<p></p><h4>notParagraph</h4>
<p></p><div>
Content of block element with blank line.

<blockquote>
hogehoge
</blockquote>
</div>
<p>
 <b>Paragraph</b> begin with tag.
</p>
<p></p><pre>
In &lt;pre&gt;, &lt; and &gt; are automatically escaped.
</pre>
<p>
Section without title and anchor.
</p>
<p><a name="p04"></a>
Section without title.
</p>
</div>
    EOF
    checkConversion(source, html)

  end

  def test_etdiary_unterminated_tag
    # -------- etDiary source
    source = <<-'EOF'
<p>
paragraph
</q>
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<p></p><p>
paragraph
</q>
</p>(tDiary warning: tag &lt;p&gt; is not terminated.)
</div>
    EOF
    checkConversion(source, html)
  end

  def test_etdiary_null
    # -------- etDiary source
    source = <<-'EOF'
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<p>
</p>
</div>
    EOF
    checkConversion(source, html)
  end

  def checkConversion(source, htmlExpected)
    diary = TDiary::EtdiaryDiary.new(Time.local(2003, 1, 1), "TITLE", source)
    htmlResult = diary.to_html({'anchor' => true})
    # puts(htmlResult)
    if htmlExpected == htmlResult
      assert(true)
    else
      assert(false, "\n-- Expected\n#{htmlExpected}\n-- Result\n#{htmlResult}")
    end
  end
end #/EtdiaryTest
