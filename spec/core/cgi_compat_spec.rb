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

	describe 'Shift_JIS fallback' do
		it 'converts a Shift_JIS query value to UTF-8' do
			sjis = 'こんにちは'.encode(Encoding::Shift_JIS)
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => "greeting=#{CGI.escape(sjis.b)}" })
			expect(cgi.params['greeting']).to eq ['こんにちは']
			expect(cgi.params['greeting'][0].encoding).to eq Encoding::UTF_8
		end

		it 'converts a Shift_JIS body value to UTF-8' do
			sjis = 'さようなら'.encode(Encoding::Shift_JIS)
			cgi = build_cgi(
				{
					'REQUEST_METHOD' => 'POST',
					'CONTENT_TYPE' => 'application/x-www-form-urlencoded'
				},
				body: "message=#{CGI.escape(sjis.b)}"
			)
			expect(cgi.params['message']).to eq ['さようなら']
		end

		it 'scrubs a value that is neither valid UTF-8 nor Shift_JIS' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => 'broken=%FF%FE%FF' })
			value = cgi.params['broken'][0]
			expect(value.encoding).to eq Encoding::UTF_8
			expect(value.valid_encoding?).to be true
			expect(value).to include("�")
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
