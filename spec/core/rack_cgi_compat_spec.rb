require 'spec_helper'
require 'stringio'
require 'rack'
require 'support/cgi_compat_shared_examples'

# Locks the behaviour of RackCGI built the same way as
# TDiary::Dispatcher#call (TDiary::Request#cgi_compat). The shared
# examples were locked against the former CGI-subclass implementation,
# proving the CGICompat-based facade keeps the @cgi surface intact.
describe RackCGI do
	def build_cgi(env, body: nil)
		rack_env = Rack::MockRequest.env_for('http://www.example.com/')
		rack_env.merge!(env)
		if body
			rack_env['CONTENT_LENGTH'] = body.bytesize.to_s
			rack_env['rack.input'] = StringIO.new(body)
		end
		TDiary::Request.new(rack_env).cgi_compat
	end

	it_behaves_like 'CGI compatible request facade'

	it 'is a RackCGI' do
		expect(build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '' })).to be_a(RackCGI)
	end

	it 'is memoized on the request' do
		request = TDiary::Request.new(Rack::MockRequest.env_for('http://www.example.com/'))
		expect(request.cgi_compat).to equal(request.cgi_compat)
	end

	it 'yields to a real CGI instance passed by the CGI hosting path' do
		real_cgi = Object.new
		request = TDiary::Request.new({}, real_cgi)
		expect(request.cgi_compat).to equal(real_cgi)
	end

	it 'keeps the params readable after Rack::Request consumed the body' do
		rack_env = Rack::MockRequest.env_for('http://www.example.com/')
		rack_env.merge!(
			'REQUEST_METHOD' => 'POST',
			'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
			'CONTENT_LENGTH' => '7',
			'rack.input' => StringIO.new('a=1&b=2')
		)
		request = TDiary::Request.new(rack_env)
		request.params # Rack::Request#POST reads rack.input to EOF
		expect(request.cgi_compat.params['a']).to eq ['1']
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
