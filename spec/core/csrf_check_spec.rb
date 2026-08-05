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

	describe '.csrf_origin_of' do
		it 'normalizes scheme and host to lowercase without a default port' do
			expect(described_class.csrf_origin_of('HTTP://WWW.Example.COM:80/d/update.rb')).to eq 'http://www.example.com'
		end

		it 'keeps a non-default port' do
			expect(described_class.csrf_origin_of('https://www.example.com:8443/')).to eq 'https://www.example.com:8443'
		end

		it 'accepts a URI object' do
			expect(described_class.csrf_origin_of(config_uri)).to eq 'http://www.example.com'
		end

		it 'returns nil for non-http URLs and garbage' do
			expect(described_class.csrf_origin_of('')).to be_nil
			expect(described_class.csrf_origin_of('ftp://example.com/')).to be_nil
			expect(described_class.csrf_origin_of('http://[broken')).to be_nil
		end
	end

	describe '.csrf_fetch_verdict' do
		let(:allowed_origins) { ['http://www.example.com'] }

		it 'is :same_origin when the Origin header matches' do
			expect(described_class.csrf_fetch_verdict('http://www.example.com', nil, allowed_origins)).to eq :same_origin
		end

		it 'is :cross_site when the Origin header does not match' do
			expect(described_class.csrf_fetch_verdict('http://attacker.example.org', nil, allowed_origins)).to eq :cross_site
		end

		it 'is :cross_site for an opaque Origin (null)' do
			expect(described_class.csrf_fetch_verdict('null', nil, allowed_origins)).to eq :cross_site
		end

		it 'prefers Origin over Sec-Fetch-Site' do
			expect(described_class.csrf_fetch_verdict('http://attacker.example.org', 'same-origin', allowed_origins)).to eq :cross_site
		end

		it 'is :same_origin for Sec-Fetch-Site: same-origin without Origin' do
			expect(described_class.csrf_fetch_verdict(nil, 'same-origin', allowed_origins)).to eq :same_origin
		end

		it 'is :cross_site for Sec-Fetch-Site: cross-site and same-site' do
			expect(described_class.csrf_fetch_verdict(nil, 'cross-site', allowed_origins)).to eq :cross_site
			expect(described_class.csrf_fetch_verdict(nil, 'same-site', allowed_origins)).to eq :cross_site
		end

		it 'is :unknown when both headers are absent' do
			expect(described_class.csrf_fetch_verdict(nil, nil, allowed_origins)).to eq :unknown
		end

		it 'is :unknown for Sec-Fetch-Site: none (user-initiated navigation)' do
			expect(described_class.csrf_fetch_verdict(nil, 'none', allowed_origins)).to eq :unknown
		end
	end

	describe '.csrf_provenance_ok?' do
		let(:allowed_origins) { ['http://www.example.com'] }

		def provenance_ok?(origin: nil, sec_fetch_site: nil, referer: '', regexp: '', check_referer: true)
			described_class.csrf_provenance_ok?(origin, sec_fetch_site, referer, allowed_origins, config_uri, regexp, check_referer)
		end

		it 'passes on a matching Origin regardless of the referer' do
			expect(provenance_ok?(origin: 'http://www.example.com')).to be_truthy
		end

		it 'passes on Sec-Fetch-Site: same-origin without Origin' do
			expect(provenance_ok?(sec_fetch_site: 'same-origin')).to be_truthy
		end

		it 'rejects a cross-site Origin even when check_referer is disabled' do
			expect(provenance_ok?(origin: 'http://attacker.example.org', check_referer: false)).to be_falsey
		end

		it 'rejects Sec-Fetch-Site: cross-site even when check_referer is disabled' do
			expect(provenance_ok?(sec_fetch_site: 'cross-site', check_referer: false)).to be_falsey
		end

		it 'still honors the admin-configured referer regexp on a cross-site verdict' do
			regexp = '\Ahttp://alt\.example\.org/'
			expect(provenance_ok?(origin: 'http://alt.example.org', referer: 'http://alt.example.org/editor.html', regexp: regexp)).to be_truthy
		end

		context 'when Origin and Sec-Fetch-Site are both absent' do
			it 'falls back to the referer check: update page referer passes' do
				expect(provenance_ok?(referer: 'http://www.example.com/d/update.rb')).to be_truthy
			end

			it 'falls back to the referer check: another page is rejected' do
				expect(provenance_ok?(referer: 'http://attacker.example.org/')).to be_falsey
			end

			it 'rejects an empty referer when check_referer is enabled' do
				expect(provenance_ok?(referer: '')).to be_falsey
			end

			it 'tolerates an empty referer when check_referer is disabled' do
				expect(provenance_ok?(referer: '', check_referer: false)).to be_truthy
			end
		end

		it 'treats Sec-Fetch-Site: none like an absent signal' do
			expect(provenance_ok?(sec_fetch_site: 'none', referer: '', check_referer: false)).to be_truthy
			expect(provenance_ok?(sec_fetch_site: 'none', referer: '', check_referer: true)).to be_falsey
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
