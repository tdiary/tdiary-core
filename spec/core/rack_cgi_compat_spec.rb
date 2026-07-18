require 'spec_helper'
require 'stringio'
require 'rack'
require 'tdiary/application' # applies the CGI#env_table patch used by RackCGI
require 'support/cgi_compat_shared_examples'
require 'support/rack_cgi_globals'

# Locks the current behaviour of RackCGI built the same way as
# TDiary::Dispatcher#call (adopt_rack_request_to_plain_old_tdiary_style).
describe RackCGI do
	include_context 'preserving RackCGI globals'

	def build_cgi(env, body: nil)
		rack_env = Rack::MockRequest.env_for('http://www.example.com/')
		rack_env.merge!(env)
		rack_env['CONTENT_LENGTH'] = body.bytesize.to_s if body
		$RACK_ENV = rack_env
		$stdin = StringIO.new(body || '')
		RackCGI.new
	end

	it_behaves_like 'CGI compatible request facade'

	it 'is a RackCGI' do
		expect(build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '' })).to be_a(RackCGI)
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
