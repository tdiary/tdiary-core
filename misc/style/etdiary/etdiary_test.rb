#!/usr/bin/env ruby
#-*-ruby-*-
require "test/unit"

thisdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << thisdir
$LOAD_PATH << "#{thisdir}/../../.."

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
<h4>notParagraph</h4>
<div>
Content of block element with blank line.

<blockquote>
hogehoge
</blockquote>
</div>
<p>
 <b>Paragraph</b> begin with tag.
</p>
<pre>
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
<p>
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

  def test_etdiary_sectionAtBeginning
    # -------- etDiary source
    source = <<-'EOF'
<<hoge>>
fuga
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<h3>hoge</h3>
<p>
fuga
</p>
</div>
    EOF

    checkConversion(source, html)
  end

  def test_etdiary_appending
    # -------- etDiary source
    source = <<-'EOF'
<p>para1</p>
    EOF

    # -------- etDiary source (appended)
    sourceAppended = <<-'EOF'
<p>para2</p>
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<p>para1</p>
<p>para2</p>
</div>
    EOF
    preConvertHtml = proc { |diary|
      diary.append(sourceAppended)
    }
    checkConversion(source, html, :preConvertHtml => preConvertHtml)
  end

  # 2004.08.12 Reported by Shun-ichi TAHARA, thanks!
  def test_etdiary_subsequentPREtoSectionTitle
    # -------- etDiary source
    source = <<-'EOF'
<<hoge>>
<pre>
hoge

fuga
</pre>
    EOF

    # -------- HTML
    html = <<-'EOF'
<div class="section">
<h3>hoge</h3>
<pre>
hoge

fuga
</pre>
</div>
    EOF

    checkConversion(source, html)
  end

  # 2004.08.19 Reported by Shun-ichi TAHARA, thanks!
  def test_etdiary_badAnchorNumber
    source = <<-'EOF'
sect0-para0

<<sect1>>
sect1-para0

sect1-para1

sect1-para2

<<sect2>>
sect2-para0
    EOF
    diary = TDiary::EtdiaryDiary.new(Time.local(2003, 1, 1), "TITLE", "")
    diary.append(source)
    sections = []
    diary.each_section { |sect|
      sections << sect
    }

    anchorNumber = 0
    sections.find { |sect|
      anchorNumber += 1
      (sect.subtitle == "sect2")
    } or assert_fail("Section not found.")
    assert_equal(2, anchorNumber)
  end

  def checkConversion(source, htmlExpected, opt = nil)
    opt ||= {}
    diary = TDiary::EtdiaryDiary.new(Time.local(2003, 1, 1), "TITLE", "")
    diary.append(source)
    if opt[:preConvertHtml]
      opt[:preConvertHtml].call(diary)
    end
    htmlResult = diary.to_html({'anchor' => true})
    if htmlExpected == htmlResult
      assert(true)
    else
      $diffOutput ||= File.open("etdiary_test.diff", "w")
      require "tempfile"
      files = [htmlExpected, htmlResult].collect { |content|
        tmpfile = Tempfile.new("etdiary")
        tmpfile.write(content)
        tmpfile.flush
        tmpfile.path
      }
      $diffOutput.print(`diff -u #{files[0]} #{files[1]}`)
      assert(false, "(See etdiary_test.diff)\n-- Expected\n#{htmlExpected}\n-- Result\n#{htmlResult}")
    end
  end
end #/EtdiaryTest
