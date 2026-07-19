require 'spec_helper'
require 'open3'
require 'tmpdir'
require 'rbconfig'

# Smoke test running index.rb as a real CGI process, locking the plain CGI
# hosting path (no Rack, @cgi is a plain CGI instance).
describe 'index.rb as a plain CGI program' do
	before(:all) do
		repo_root = File.expand_path('../../..', __FILE__)
		@workdir = Dir.mktmpdir('tdiary-cgi-smoke')
		data_dir = File.join(@workdir, 'tmp/data')
		FileUtils.mkdir_p data_dir
		# tdiary.conf.webrick resolves @data_path against the working directory
		FileUtils.cp File.join(repo_root, 'spec/fixtures/tdiary.conf.webrick'), File.join(@workdir, 'tdiary.conf')
		FileUtils.cp File.join(repo_root, 'spec/fixtures/just_installed.conf'), File.join(data_dir, 'tdiary.conf')

		env = {
			'GATEWAY_INTERFACE' => 'CGI/1.1',
			'REQUEST_METHOD' => 'GET',
			'QUERY_STRING' => '',
			'SCRIPT_NAME' => '/index.rb',
			'SERVER_NAME' => 'www.example.com',
			'SERVER_PORT' => '80',
			'HTTP_HOST' => 'www.example.com',
			'SERVER_PROTOCOL' => 'HTTP/1.1',
			'REMOTE_ADDR' => '127.0.0.1'
		}
		stdout, @stderr, @process_status = Open3.capture3(env, RbConfig.ruby, File.join(repo_root, 'index.rb'), chdir: @workdir)
		@head, _separator, @body = stdout.partition(/\r?\n\r?\n/)
	end

	after(:all) do
		FileUtils.remove_entry @workdir
	end

	it 'responds with Status 200 and an HTML body' do
		expect(@head).to match(/^Status: 200/), -> { "head: #{@head.inspect}\nstderr: #{@stderr}" }
		expect(@body).to include('<html')
	end

	it 'links css under theme/ and scripts under js/' do
		expect(@body).to match(%r|<link rel="stylesheet" href="theme/base\.css"|)
		expect(@body).to match(%r|<script src="js/00default\.js|)
	end
end

# Locks the POST path and the expansion of Array header values (Set-Cookie)
# into one header line each.
describe 'index.rb comment POST as a plain CGI program' do
	before(:all) do
		repo_root = File.expand_path('../../..', __FILE__)
		@workdir = Dir.mktmpdir('tdiary-cgi-smoke')
		data_dir = File.join(@workdir, 'tmp/data')
		FileUtils.mkdir_p File.join(data_dir, '2026')
		FileUtils.cp File.join(repo_root, 'spec/fixtures/tdiary.conf.webrick'), File.join(@workdir, 'tdiary.conf')
		FileUtils.cp File.join(repo_root, 'spec/fixtures/just_installed.conf'), File.join(data_dir, 'tdiary.conf')
		File.write File.join(data_dir, '2026/202607.td2'), <<~TD2
			TDIARY2.01.00
			Date: 20260719
			Title: smoke
			Last-Modified: 1784000000
			Visible: true
			Format: Wiki

			an entry to comment on
			.
		TD2

		body = 'date=20260719&name=alice&mail=alice%40example.com&body=hello&comment=comment'
		env = {
			'GATEWAY_INTERFACE' => 'CGI/1.1',
			'REQUEST_METHOD' => 'POST',
			'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
			'CONTENT_LENGTH' => body.bytesize.to_s,
			'QUERY_STRING' => '',
			'SCRIPT_NAME' => '/index.rb',
			'SERVER_NAME' => 'www.example.com',
			'SERVER_PORT' => '80',
			'HTTP_HOST' => 'www.example.com',
			'SERVER_PROTOCOL' => 'HTTP/1.1',
			'REMOTE_ADDR' => '127.0.0.1'
		}
		stdout, @stderr, @process_status = Open3.capture3(env, RbConfig.ruby, File.join(repo_root, 'index.rb'), stdin_data: body, chdir: @workdir)
		@head, _separator, @body = stdout.partition(/\r?\n\r?\n/)
	end

	after(:all) do
		FileUtils.remove_entry @workdir
	end

	it 'accepts the comment and sets the tdiary cookie' do
		expect(@head).to match(/^Status: 200/), -> { "head: #{@head.inspect}\nstderr: #{@stderr}" }
		expect(@head).to match(/^set-cookie: tdiary=alice/i), -> { "head: #{@head.inspect}\nstderr: #{@stderr}" }
		expect(@body).to include('Click here!')
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
