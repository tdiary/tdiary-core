# -*- coding: utf-8; -*-
require 'spec_helper'

require 'tdiary'
require 'misc/style/gfm/gfm_style'

describe TDiary::GfmDiary do
	before do
		@diary = TDiary::GfmDiary.new(Time.at( 1041346800 ), "TITLE", "")
	end

	describe '#append' do
		before do
			@source = <<-'EOF'
# subTitle
honbun

## subTitleH4
honbun

			EOF
			@diary.append(@source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>

<h4>subTitleH4</h4>

<p>honbun</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
				EOF
			end
			it { @diary.to_html.should eq @html }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p>honbun</p>

<h4>subTitleH4</h4>

<p>honbun</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
				EOF
			end
			it { @diary.to_html({}, :CHTML).should eq @html }
		end

		context 'to_src' do
			it { @diary.to_src.should eq @source }
		end
	end

	describe '#replace' do
		before do
			source = <<-'EOF'
# subTitle
honbun

## subTitleH4
honbun

			EOF
			@diary.append(source)

			replaced = <<-'EOF'
# replaceTitle
replace

## replaceTitleH4
replace

			EOF
			@diary.replace(Time.at( 1041346800 ), "TITLE", replaced)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "replaceTitle" ) %></h3>
<p>replace</p>

<h4>replaceTitleH4</h4>

<p>replace</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'autolink' do
		before do
			source = <<-EOF
# subTitle

 * http://www.google.com

[google](https://www.google.com)

http://www.google.com
         EOF
			@diary.append(source)
			@html = <<-EOF
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<ul>
<li><a href="http://www.google.com" rel="nofollow">http://www.google.com</a></li>
</ul>

<p><a href="https://www.google.com" rel="nofollow">google</a></p>

<p><a href="http://www.google.com" rel="nofollow">http://www.google.com</a></p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
         EOF
		end

		it { @diary.to_html.should eq @html }
	end

	describe 'url syntax with code blocks' do
		before do
			source = <<-'EOF'
# subTitle

```ruby
@foo
```

http://example.com is example.com

			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<div class="highlight"><pre><span class="vi">@foo</span>
</pre></div>
<p><a href="http://example.com" rel="nofollow">http://example.com</a> is example.com</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'ignored url syntax with markdown anchor' do
		before do
			source = <<-'EOF'
# subTitle

[example](http://example.com) is example.com

			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p><a href="http://example.com" rel="nofollow">example</a> is example.com</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'plugin syntax' do
		before do
			source = <<-'EOF'
# subTitle
{{plugin 'val'}}

{{plugin "val", 'val'}}

			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p><%=plugin 'val'%></p>

<p><%=plugin "val", 'val'%></p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'plugin syntax with url args' do
		before do
			source = <<-'EOF'
# subTitle
{{plugin 'http://www.example.com/foo.html', "https://www.example.com/bar.html"}}

			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p><%=plugin 'http://www.example.com/foo.html', "https://www.example.com/bar.html"%></p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'link to my plugin' do
		before do
			source = <<-'EOF'
# subTitle

()[20120101p01]

(Link)[20120101p01]

			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p><%=my "20120101p01", "20120101p01" %></p>

<p><%=my "20120101p01", "Link" %></p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'code highlighting' do
		before do
			source = <<-'EOF'
# subTitle

```ruby
 def class
   @foo = 'bar'
 end
 ```
			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<div class="highlight"><pre> <span class="k">def</span> <span class="nf">class</span>
   <span class="vi">@foo</span> <span class="o">=</span> <span class="s1">&#39;bar&#39;</span>
 <span class="k">end</span>
</pre></div><%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'ignore emphasis' do
		before do
			source = <<-'EOF'
# subTitle

@a_matsuda is amatsuda

{{isbn_left_image ''}}
			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p>@<a class="tweet-url username" href="https://twitter.com/a_matsuda" rel="nofollow">a_matsuda</a> is amatsuda</p>

<p><%=isbn_left_image ''%></p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end

	describe 'emoji' do
		before do
			source = <<-'EOF'
# subTitle

:sushi: は美味しい
			EOF
			@diary.append(source)

			@html = <<-'EOF'
<div class="section">
<%=section_enter_proc( Time.at( 1041346800 ) )%>
<h3><%= subtitle_proc( Time.at( 1041346800 ), "subTitle" ) %></h3>
<p><img src='http://www.emoji-cheat-sheet.com/graphics/emojis/sushi.png' width='20' height='20' title='sushi' alt='sushi' class='emoji' /> は美味しい</p>
<%=section_leave_proc( Time.at( 1041346800 ) )%>
</div>
			EOF
		end
		it { @diary.to_html.should eq @html }
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
