# -*- coding: utf-8 -*-
require 'spec_helper'

require 'tdiary/core_ext'

describe "core extension library" do
	describe 'String#make_link' do
		it 'エスケープされて出力される' do
			expect("<\"alice&bob\">".make_link).to eq "&lt;&quot;alice&amp;bob&quot;&gt;"
		end

		context 'httpを含む場合' do
			it { expect("http://example.com".make_link).to eq "<a href=\"http://example.com\">http://example.com</a>" }
		end

		context 'メールアドレスのようなものを含む場合' do
			it { expect("shibata.hiroshi@gmail.com".make_link).to eq "<a href=\"mailto:shibata.hiroshi@gmail.com\">shibata.hiroshi@gmail.com</a>" }
		end
	end

	describe "String#emojify!" do
		context "emojify" do
			before { @result = ":sushi: は美味しい".emojify }
			it do
				expect(@result).to eq "<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/sushi.png' width='20' height='20' title='sushi' alt='sushi' class='emoji' /> は美味しい"
			end
		end

		context "大文字でもemojify" do
			before { @result = ":SUSHI: は美味しい".emojify }
			it do
				expect(@result).to eq "<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/sushi.png' width='20' height='20' title='sushi' alt='sushi' class='emoji' /> は美味しい"
			end
		end

		context "+1でもemojify" do
			before { @result = "いいね!:+1:".emojify }
			it do
				expect(@result).to eq "いいね!<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/plus1.png' width='20' height='20' title='plus1' alt='plus1' class='emoji' />"
			end
		end

		context "文字と数字しか変換しない" do
			before do
				@result = ":<script type='text/javascript'></script>: は美味しい".emojify
			end
			it do
				expect(@result).to eq ":<script type='text/javascript'></script>: は美味しい"
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
