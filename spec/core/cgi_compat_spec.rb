require 'spec_helper'
require 'stringio'
require 'rack'
require 'support/cgi_compat_shared_examples'

describe TDiary::CGICompat do
	def build_cgi(env, body: nil)
		rack_env = Rack::MockRequest.env_for('http://www.example.com/')
		rack_env.merge!(env)
		if body
			rack_env['CONTENT_LENGTH'] = body.bytesize.to_s
			rack_env['rack.input'] = StringIO.new(body)
		end
		TDiary::CGICompat.new(TDiary::Request.new(rack_env))
	end

	it_behaves_like 'CGI compatible request facade'

	it 'exposes the wrapped request' do
		cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '' })
		expect(cgi.request).to be_a(TDiary::Request)
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
