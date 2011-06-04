# -*- coding: utf-8 -*-
require 'spec_helper'

require 'tdiary/core_ext'

describe "core extension library" do
  describe 'String#make_link' do
    it 'エスケープされて出力される' do
      "<\"alice&bob\">".make_link.should eq "&lt;&quot;alice&amp;bob&quot;&gt;"
    end

    context 'httpを含む場合' do
      it { "http://example.com".make_link.should eq "<a href=\"http://example.com\">http://example.com</a>" }
    end

    context 'メールアドレスのようなものを含む場合' do
      it { "shibata.hiroshi@gmail.com".make_link.should eq "<a href=\"mailto:shibata.hiroshi@gmail.com\">shibata.hiroshi@gmail.com</a>" }
    end
  end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
