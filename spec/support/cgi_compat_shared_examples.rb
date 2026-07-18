# Shared examples locking the @cgi compatible surface consumed by plugins
# and view controllers. The including context must provide:
#
#    build_cgi(env, body: nil)  # => an object compatible with @cgi
#
# where env is a Hash of CGI-style environment variables and body is the
# raw request body for POST requests.
RSpec.shared_examples 'CGI compatible request facade' do
	describe 'params' do
		context 'with GET query string' do
			let(:cgi) { build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => 'a=1&a=2&b=%E3%81%82' }) }

			it 'collects multiple values into an array' do
				expect(cgi.params['a']).to eq ['1', '2']
			end

			it 'unescapes values as UTF-8' do
				expect(cgi.params['b']).to eq ['あ']
				expect(cgi.params['b'][0].encoding).to eq Encoding::UTF_8
			end

			it 'returns an empty array for unknown keys' do
				expect(cgi.params['nothing']).to eq []
				expect(cgi.params['nothing'][0]).to be_nil
			end

			it 'is memoized and mutable' do
				cgi.params['date'] = ['20260101']
				expect(cgi.params['date']).to eq ['20260101']
			end
		end

		context 'with POST body' do
			let(:cgi) {
				build_cgi(
					{
						'REQUEST_METHOD' => 'POST',
						'QUERY_STRING' => 'c=3',
						'CONTENT_TYPE' => 'application/x-www-form-urlencoded'
					},
					body: 'a=1&b=2'
				)
			}

			it 'parses parameters from the body' do
				expect(cgi.params['a']).to eq ['1']
				expect(cgi.params['b']).to eq ['2']
			end

			it 'ignores the query string' do
				expect(cgi.params['c']).to eq []
			end
		end
	end

	describe 'valid?' do
		let(:cgi) { build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => 'a=1&a=2&empty=' }) }

		it { expect(cgi.valid?('a')).to be_truthy }
		it { expect(cgi.valid?('nothing')).to be_falsey }
		it { expect(cgi.valid?('empty')).to be_falsey }
		it { expect(cgi.valid?('a', 1)).to be_truthy }
		it { expect(cgi.valid?('a', 2)).to be_falsey }
	end

	describe 'clone' do
		let(:cgi) { build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => 'date=20260101' }) }

		# 00default.rb calc_links backups params['date'], mutates params of a
		# clone and restores it afterwards, relying on the clone sharing the
		# same params Hash.
		it 'shares the params Hash with the clone' do
			c2 = cgi.clone
			c2.params['date'] = ['x']
			expect(cgi.params['date']).to eq ['x']
		end
	end

	describe 'cookies' do
		let(:cgi) {
			build_cgi({
				'REQUEST_METHOD' => 'GET',
				'QUERY_STRING' => '',
				'HTTP_COOKIE' => 'tdiary=%E3%81%82&foo%40example.com'
			})
		}

		it 'unescapes multiple values' do
			expect(cgi.cookies['tdiary'][0]).to eq 'あ'
			expect(cgi.cookies['tdiary'][1]).to eq 'foo@example.com'
		end

		it 'returns nil value for unknown keys' do
			expect(cgi.cookies['nope'][0]).to be_nil
		end
	end

	describe 'environment readers' do
		let(:cgi) {
			build_cgi({
				'REQUEST_METHOD' => 'GET',
				'QUERY_STRING' => '',
				'HTTP_REFERER' => 'http://example.net/from',
				'HTTP_USER_AGENT' => 'test-agent',
				'REMOTE_ADDR' => '192.0.2.1',
				'SCRIPT_NAME' => '/index.rb',
				'REMOTE_USER' => 'alice',
				'AUTH_TYPE' => 'Basic',
				'GATEWAY_INTERFACE' => 'CGI/1.1',
				'HTTP_X_SOMETHING' => 'x-value'
			})
		}

		it { expect(cgi.referer).to eq 'http://example.net/from' }
		it { expect(cgi.user_agent).to eq 'test-agent' }
		it { expect(cgi.remote_addr).to eq '192.0.2.1' }
		it { expect(cgi.request_method).to eq 'GET' }
		it { expect(cgi.script_name).to eq '/index.rb' }
		it { expect(cgi.remote_user).to eq 'alice' }
		it { expect(cgi.auth_type).to eq 'Basic' }
		it { expect(cgi.gateway_interface).to eq 'CGI/1.1' }
		it { expect(cgi.env_table['HTTP_X_SOMETHING']).to eq 'x-value' }
	end

	describe 'base_url' do
		def build_url_cgi(env)
			build_cgi({
				'REQUEST_METHOD' => 'GET',
				'QUERY_STRING' => '',
				'SERVER_NAME' => 'www.example.com',
				'SCRIPT_NAME' => '/index.rb'
			}.merge(env))
		end

		it 'omits the default http port' do
			cgi = build_url_cgi('SERVER_PORT' => '80')
			expect(cgi.base_url).to eq 'http://www.example.com/'
		end

		it 'appends a non default port' do
			cgi = build_url_cgi('SERVER_PORT' => '8080')
			expect(cgi.base_url).to eq 'http://www.example.com:8080/'
		end

		it 'omits the default https port when HTTPS=on' do
			cgi = build_url_cgi('SERVER_PORT' => '443', 'HTTPS' => 'on')
			expect(cgi.base_url).to eq 'https://www.example.com/'
		end

		it 'uses https when X-Forwarded-Proto is https' do
			cgi = build_url_cgi('SERVER_PORT' => '443', 'HTTP_X_FORWARDED_PROTO' => 'https')
			expect(cgi.base_url).to eq 'https://www.example.com/'
		end

		# current quirk: SERVER_PORT is kept as is even when the scheme is
		# switched to https by X-Forwarded-Proto
		it 'keeps port 80 when X-Forwarded-Proto is https' do
			cgi = build_url_cgi('SERVER_PORT' => '80', 'HTTP_X_FORWARDED_PROTO' => 'https')
			expect(cgi.base_url).to eq 'https://www.example.com:80/'
		end

		it 'appends the directory of SCRIPT_NAME' do
			cgi = build_url_cgi('SERVER_PORT' => '80', 'SCRIPT_NAME' => '/diary/index.rb')
			expect(cgi.base_url).to eq 'http://www.example.com/diary/'
		end
	end

	describe 'https?' do
		it 'is false without HTTPS' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '' })
			expect(cgi.https?).to be false
		end

		it 'is false when HTTPS=off' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '', 'HTTPS' => 'off' })
			expect(cgi.https?).to be false
		end

		it 'is true when HTTPS=on' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '', 'HTTPS' => 'on' })
			expect(cgi.https?).to be true
		end

		it 'is true when X-Forwarded-Proto is https' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '', 'HTTP_X_FORWARDED_PROTO' => 'https' })
			expect(cgi.https?).to be true
		end
	end

	describe 'request_uri' do
		it 'returns REQUEST_URI when given' do
			cgi = build_cgi({
				'REQUEST_METHOD' => 'GET',
				'QUERY_STRING' => 'date=20260101',
				'SCRIPT_NAME' => '/diary/index.rb',
				'REQUEST_URI' => '/diary/index.rb?date=20260101'
			})
			expect(cgi.request_uri).to eq '/diary/index.rb?date=20260101'
		end

		it 'composes from IIS style PATH_INFO without REQUEST_URI' do
			cgi = build_cgi({
				'REQUEST_METHOD' => 'GET',
				'QUERY_STRING' => '',
				'SCRIPT_NAME' => '/diary/index.rb',
				'PATH_INFO' => '/diary/index.rb/20260101.html'
			})
			expect(cgi.request_uri).to eq '/diary/index.rb/20260101.html'
		end
	end

	describe 'redirect_url' do
		it 'returns REDIRECT_URL' do
			cgi = build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '', 'REDIRECT_URL' => '/redirected' })
			expect(cgi.redirect_url).to eq '/redirected'
		end
	end

	describe 'mobile' do
		let(:cgi) { build_cgi({ 'REQUEST_METHOD' => 'GET', 'QUERY_STRING' => '' }) }

		it { expect(cgi.mobile_agent?).to be false }
		it { expect(cgi.smartphone?).to be false }
	end

	describe 'multipart POST' do
		let(:boundary) { 'AaB03x' }
		let(:multipart_body) {
			[
				"--#{boundary}",
				'Content-Disposition: form-data; name="date"; filename="date.txt"',
				'Content-Type: text/plain',
				'',
				'20260101',
				"--#{boundary}",
				'Content-Disposition: form-data; name="title"',
				'',
				'multipart title',
				"--#{boundary}--",
				''
			].join("\r\n")
		}
		let(:cgi) {
			build_cgi(
				{
					'REQUEST_METHOD' => 'POST',
					'CONTENT_TYPE' => "multipart/form-data; boundary=#{boundary}"
				},
				body: multipart_body
			)
		}

		# The raw value type (String or IO) is not fixed here. The only
		# consumer of file uploads normalizes values with this pattern
		# (TDiary::TDiaryFormPlugin in lib/tdiary/author_only_base.rb).
		def read_value(value)
			value.kind_of?(String) ? value : value.read
		end

		it 'provides the file field content' do
			expect(read_value(cgi.params['date'][0])).to eq '20260101'
		end

		it 'provides the plain field content' do
			expect(read_value(cgi.params['title'][0])).to eq 'multipart title'
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
