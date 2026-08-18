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

	describe '#params' do
		# the update dispatcher branches on request.params, and
		# 00default.rb generates ';'-separated edit links
		it 'splits the query string on semicolons like CGI' do
			request = build_request('QUERY_STRING' => 'edit=true;year=2026;month=8;day=9')
			expect(request.params).to eq({ 'edit' => 'true', 'year' => '2026', 'month' => '8', 'day' => '9' })
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
