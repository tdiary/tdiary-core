require 'spec_helper'

require 'tdiary'
require 'tdiary/style/tdiary'

describe TDiary::Style::TdiaryDiary do
	before :all do
		klass = TDiary::Style::TdiaryDiary
		klass.send(:include, TDiary::Style::BaseDiary)
		klass.send(:include, TDiary::Style::CategorizableDiary)
	end

	before do
		@diary = TDiary::Style::TdiaryDiary.new(Time::at( 1041346800 ), "TITLE", "")
	end

	describe '#append' do
		before do
			@source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>

			EOF
			@diary.append(@source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
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
			end
			it { expect(@diary.to_html).to eq @html.chomp }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></H3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></H3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
				EOF
			end
			it { expect(@diary.to_html({}, :CHTML)).to eq @html }
		end


		context 'to_src' do
			it { expect(@diary.to_src).to eq @source }
		end
	end

	describe '#replace' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF
			@diary.append(source)

			replaced = <<-'EOF'
replaceTitle
<p>replace</p>

replaceTitle2
<p>replace</p>

			EOF
			@diary.replace(Time::at( 1041346800 ), "TITLE", replaced)

			@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "replaceTitle" ) %></h3>
<p>replace</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div><div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "replaceTitle2" ) %></h3>
<p>replace</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
			EOF
		end
		it { expect(@diary.to_html).to eq @html.chomp }
	end

	describe '#add_section' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>
			EOF
			@diary.append(source)
			@diary.add_section('subTitle2', '<p>honbun</p>')

			@html = <<-'EOF'
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
		end
		it { expect(@diary.to_html).to eq @html.chomp }
	end

	describe '#delete_section' do
		before do
			source = <<-'EOF'
subTitle
<p>honbun</p>

subTitle2
<p>honbun</p>
			EOF
			@diary.append(source)
			@diary.delete_section(1)

			@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle2" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
			EOF
		end
		it { expect(@diary.to_html).to eq @html.chomp }
	end

	describe 'test_tdiary_style2' do
		before do
			source = <<-'EOF'
<<a href="http://example.com">subTitle</a>
<p>honbun</p>
			EOF
			@diary.append(source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
<div class="section">
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<h3><%= subtitle_proc( Time::at( 1041346800 ), "<a href=\"http://example.com\">subTitle</a>" ) %></h3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
</div>
				EOF
			end
			it { expect(@diary.to_html).to eq @html.chomp }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "<a href=\"http://example.com\">subTitle</a>" ) %></H3>
<p>honbun</p><%= section_leave_proc( Time::at( 1041346800 ) ) %>
				EOF
			end
			it { expect(@diary.to_html({}, :CHTML)).to eq @html }
		end
	end

	describe 'test_tdiary_style_plugin' do
		before do
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
			@diary.append(source)
		end

		context 'HTML' do
			before do
				@html = <<-'EOF'
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
			end
			it { expect(@diary.to_html).to eq @html.chomp }
		end

		context 'CHTML' do
			before do
				@html = <<-'EOF'
<%= section_enter_proc( Time::at( 1041346800 ) ) %>
<H3><%= subtitle_proc( Time::at( 1041346800 ), "subTitle" ) %></H3>
<%= plugin %>
<%= plugin %>
aaa
<%= plugin %>
a<%=ho
ge%>b
<%=ho
ge%><%= section_leave_proc( Time::at( 1041346800 ) ) %>
				EOF
			end
			it { expect(@diary.to_html({}, :CHTML)).to eq @html }
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
