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
</pre>
</div>
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
