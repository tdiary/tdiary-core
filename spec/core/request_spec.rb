require 'spec_helper'
require 'rack'

describe TDiary::Request do
	describe '#cgi_compat' do
		def build_request(env = {}, cgi = nil)
			rack_env = Rack::MockRequest.env_for('http://www.example.com/')
			rack_env.merge!(env)
			TDiary::Request.new(rack_env, cgi)
		end

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

		it 'prefers a real CGI instance regardless of the flag' do
			real_cgi = Object.new
			expect(build_request({}, real_cgi).cgi_compat).to equal(real_cgi)
			expect(build_request({ 'tdiary.static_assets' => true }, real_cgi).cgi_compat).to equal(real_cgi)
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
