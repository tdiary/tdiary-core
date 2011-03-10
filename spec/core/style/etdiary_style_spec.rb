# -*- coding: utf-8; -*-
require File.dirname(__FILE__) + '/../../spec_helper'

require 'tdiary'
require 'misc/style/etdiary/etdiary_style'

describe TDiary::EtdiaryDiary do
	before do
		@diary = TDiary::EtdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe 'test_etdiary' do
		before do
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

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p>
hogehoge
fugafuga
</p>
<p>
fugahoge
hogera
</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>

<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></h3>
<p>
honbun
</p>
<h4><%= subtitle_proc( Time::at( 1041346800 ), "subTitleH4" ) %>:</h4>
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
<p><%= subtitle_proc( Time::at( 1041346800 ), nil ) %>
Section without title and anchor.
</p>
<p><a name="p04"></a>
Section without title.
</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	describe 'test_etdiary_unterminated_tag' do
		before do
			source = <<-'EOF'
<p>
paragraph
</q>
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p>
paragraph
</q>

</p>(tDiary warning: tag &lt;p&gt; is not terminated.)
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	describe 'test_etdiary_null' do
		before do
			source = <<-'EOF'
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p>
</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	describe 'test_etdiary_sectionAtBeginning' do
		before do
			source = <<-'EOF'
<<hoge>>
fuga
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "hoge" ) %></h3>
<p>
fuga
</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	describe 'test_etdiary_appending' do
		before do
			source = <<-'EOF'
<p>para1</p>
			EOF

			sourceAppended = <<-'EOF'
<p>para2</p>
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<p>para1</p>
<p>para2</p>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF

			@diary.append(source)
			@diary.append(sourceAppended)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	# 2004.08.12 Reported by Shun-ichi TAHARA, thanks!
	describe 'test_etdiary_subsequentPREtoSectionTitle' do
		before do
			source = <<-'EOF'
<<hoge>>
<pre>
hoge

fuga
</pre>
			EOF

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time::at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "hoge" ) %></h3>
<pre>
hoge

fuga
</pre>
<%=section_leave_proc( Time::at( 1041346800 ) )%>
</div>
			EOF
			@diary.append(source)
		end
		it { @diary.to_html({'anchor' => true, 'index' => ''}).should eq @html }
	end

	# 2004.08.19 Reported by Shun-ichi TAHARA, thanks!
	describe 'test_etdiary_badAnchorNumber' do
		before do
			source = <<-'EOF'
sect0-para0

<<sect1>>
sect1-para0

sect1-para1

sect1-para2

<<sect2>>
sect2-para0
			EOF

			@diary.append(source)
			sections = []
			@diary.each_section { |sect|
				sections << sect
			}

			@anchorNumber = 0
			@section = sections.find do |sect|
				@anchorNumber += 1
				(sect.subtitle == "sect2")
			end
		end
		it { @section.should_not be_nil }
		it { @anchorNumber.should eq 2 }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
