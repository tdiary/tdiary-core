require 'spec_helper'
require 'rack'

describe TDiary::Request do
	def build_request(env = {})
		rack_env = Rack::MockRequest.env_for('http://www.example.com/')
		rack_env.merge!(env)
		TDiary::Request.new(rack_env)
	end

	describe '#cgi_compat' do
		it 'returns a RackCGI facade on the Rack path' do
			expect(build_request.cgi_compat).to be_a(RackCGI)
		end

		it 'returns the base CGICompat facade when tdiary.static_assets is set' do
			cgi_compat = build_request('tdiary.static_assets' => true).cgi_compat
			expect(cgi_compat).to be_a(TDiary::CGICompat)
			expect(cgi_compat).not_to be_a(RackCGI)
		end

		it 'is memoized on the request' do
			request = build_request('tdiary.static_assets' => true)
			expect(request.cgi_compat).to equal(request.cgi_compat)
		end
	end

	describe '#static_assets?' do
		it 'is false on the Rack path' do
			expect(build_request.static_assets?).to be false
		end

		it 'is true when tdiary.static_assets is set' do
			expect(build_request('tdiary.static_assets' => true).static_assets?).to be true
		end

		it 'is visible through the cgi_compat facade' do
			expect(build_request.cgi_compat.static_assets?).to be false
			expect(build_request('tdiary.static_assets' => true).cgi_compat.static_assets?).to be true
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
