require 'spec_helper'
require 'uri'

describe TDiary::TDiaryAuthorOnlyBase do
	let(:config_uri) { URI.parse('http://www.example.com/d/') + 'update.rb' }

	describe '.csrf_referer_allowed?' do
		it 'accepts the update page itself' do
			expect(described_class.csrf_referer_allowed?('http://www.example.com/d/update.rb', config_uri, '')).to be_truthy
		end

		it 'rejects another page on the same site' do
			expect(described_class.csrf_referer_allowed?('http://www.example.com/d/index.rb', config_uri, '')).to be_falsey
		end

		it 'rejects a cross-site referer' do
			expect(described_class.csrf_referer_allowed?('http://attacker.example.org/d/update.rb', config_uri, '')).to be_falsey
		end

		it 'accepts a referer matching the admin-configured regexp' do
			regexp = '\Ahttp://alt\.example\.org/'
			expect(described_class.csrf_referer_allowed?('http://alt.example.org/editor.html', config_uri, regexp)).to be_truthy
		end

		it 'rejects a referer not matching the admin-configured regexp' do
			regexp = '\Ahttp://alt\.example\.org/'
			expect(described_class.csrf_referer_allowed?('http://attacker.example.org/editor.html', config_uri, regexp)).to be_falsey
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
