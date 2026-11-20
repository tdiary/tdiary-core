require 'spec_helper'
require 'rack/test'
require 'tmpdir'
require 'tdiary/rack/auth/basic'

describe TDiary::Rack::Auth::Basic do
	include Rack::Test::Methods

	around do |example|
		Dir.mktmpdir do |dir|
			@htpasswd = File.join(dir, '.htpasswd')
			example.run
		end
	end

	let(:app) { TDiary::Rack::Auth::Basic.new(lambda{|env| [200, {}, ['Awesome']]}, @htpasswd) }

	describe 'bcrypt password file' do
		before do
			# created by `htpasswd -cbB .htpasswd alice 'secret passphrase'`
			File.write(@htpasswd, "alice:$2y$05$gDJJdu6rLpNcPJCwlLRrKO8XBRlvFCIKBQvmWQA97L7xWZeVDWb12\n")
		end

		it 'accepts the right password' do
			basic_authorize 'alice', 'secret passphrase'
			get '/'
			expect(last_response).to be_ok
		end

		it 'rejects a wrong password' do
			basic_authorize 'alice', 'secret'
			get '/'
			expect(last_response.status).to eq 401
		end

		it 'rejects an unknown user' do
			basic_authorize 'bob', 'secret passphrase'
			get '/'
			expect(last_response.status).to eq 401
		end
	end

	describe 'crypt password file' do
		before do
			# created by `htpasswd -cbd .htpasswd alice 'secret passphrase'`
			File.write(@htpasswd, "alice:EY.0WvbqI6dx2\n")
		end

		it 'accepts the right password' do
			basic_authorize 'alice', 'secret passphrase'
			get '/'
			expect(last_response).to be_ok
		end

		it 'rejects a wrong password' do
			basic_authorize 'alice', 'secret'
			get '/'
			expect(last_response.status).to eq 401
		end
	end

	it 'reads each user in its own format' do
		File.write(@htpasswd, "alice:EY.0WvbqI6dx2\nbob:$2y$05$gDJJdu6rLpNcPJCwlLRrKO8XBRlvFCIKBQvmWQA97L7xWZeVDWb12\n")
		basic_authorize 'bob', 'secret passphrase'
		get '/'
		expect(last_response).to be_ok
	end

	it 'returns 403 for an MD5 password' do
		# created by `htpasswd -cbm .htpasswd alice 'secret passphrase'`
		File.write(@htpasswd, "alice:$apr1$9ZQEBi2u$x4VwGYNHzkXS/.kJV7jBh1\n")
		basic_authorize 'alice', 'secret passphrase'
		get '/'
		expect(last_response.status).to eq 403
		expect(last_response.body).to include('tdiary htpasswd')
	end

	it 'returns 403 without a password file' do
		basic_authorize 'alice', 'secret passphrase'
		get '/'
		expect(last_response.status).to eq 403
	end

	it 'rejects a NUL byte in the password' do
		File.write(@htpasswd, "alice:EY.0WvbqI6dx2\nbob:$2y$05$gDJJdu6rLpNcPJCwlLRrKO8XBRlvFCIKBQvmWQA97L7xWZeVDWb12\n")
		%w(alice bob).each do |user|
			basic_authorize user, "secret passphrase\0"
			get '/'
			expect(last_response.status).to eq 401
		end
	end

	it 'returns 403 when this Ruby cannot verify a crypt password' do
		File.write(@htpasswd, "alice:EY.0WvbqI6dx2\n")
		allow_any_instance_of(String).to receive(:crypt).and_raise(NotImplementedError)
		basic_authorize 'alice', 'secret passphrase'
		get '/'
		expect(last_response.status).to eq 403
		expect(last_response.body).to include('tdiary htpasswd')
	end

	it 'returns 403 when the bcrypt gem cannot be loaded' do
		File.write(@htpasswd, "alice:$2y$05$gDJJdu6rLpNcPJCwlLRrKO8XBRlvFCIKBQvmWQA97L7xWZeVDWb12\n")
		allow_any_instance_of(TDiary::Rack::Auth::Basic).to receive(:require).with('bcrypt').and_raise(LoadError)
		basic_authorize 'alice', 'secret passphrase'
		get '/'
		expect(last_response.status).to eq 403
		expect(last_response.body).to include('BUNDLE_WITHOUT')
	end

	describe '.write_password' do
		it 'creates the file' do
			TDiary::Rack::Auth::Basic.write_password(@htpasswd, 'alice', 'secret passphrase')
			basic_authorize 'alice', 'secret passphrase'
			get '/'
			expect(last_response).to be_ok
		end

		it 'replaces only the line of the user' do
			File.write(@htpasswd, "alice:EY.0WvbqI6dx2\nbob:EY.0WvbqI6dx2\n")
			TDiary::Rack::Auth::Basic.write_password(@htpasswd, 'alice', 'new passphrase')
			expect(File.readlines(@htpasswd, chomp: true)).to match [/\Aalice:\$2a\$10\$/, 'bob:EY.0WvbqI6dx2']

			basic_authorize 'alice', 'new passphrase'
			get '/'
			expect(last_response).to be_ok
			basic_authorize 'bob', 'secret passphrase'
			get '/'
			expect(last_response).to be_ok
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
