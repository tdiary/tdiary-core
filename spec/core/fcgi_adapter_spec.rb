require 'spec_helper'
require 'tdiary/fcgi_adapter'
require 'stringio'

class MockFCGIRequest
	attr_reader :env, :in, :out, :err

	def initialize( env = {}, body: '' )
		@env = env
		@in = StringIO.new( body )
		@out = StringIO.new( ''.b )
		@err = StringIO.new
		@finished = false
	end

	def finish
		@finished = true
	end

	def finished?
		@finished
	end
end

describe TDiary::FCGIAdapter do
	def fcgi_env( overrides = {} )
		{
			'REQUEST_METHOD' => 'GET',
			'SCRIPT_NAME' => '/diary/index.fcgi',
			'PATH_INFO' => '',
			'QUERY_STRING' => 'date=20260719',
			'SERVER_NAME' => 'example.com',
			'SERVER_PORT' => '80',
		}.merge( overrides )
	end

	describe '.build_env' do
		def build_env( overrides = {}, body: '' )
			described_class.build_env( fcgi_env( overrides ), StringIO.new( body ), StringIO.new )
		end

		it 'buffers the request body into a binary rack.input' do
			env = build_env( body: 'title=foo&body=bar' )
			expect( env['rack.input'].read ).to eq 'title=foo&body=bar'
			expect( env['rack.input'].string.encoding ).to eq Encoding::ASCII_8BIT
		end

		it 'wires the request error stream to rack.errors' do
			errors = StringIO.new
			env = described_class.build_env( fcgi_env, StringIO.new, errors )
			expect( env['rack.errors'] ).to equal errors
		end

		it 'sets the tdiary.cgi_hosting flag' do
			expect( build_env['tdiary.cgi_hosting'] ).to be true
		end

		it 'removes HTTP_CONTENT_LENGTH' do
			env = build_env( { 'HTTP_CONTENT_LENGTH' => '12' } )
			expect( env ).not_to have_key 'HTTP_CONTENT_LENGTH'
		end

		it 'normalizes SCRIPT_NAME "/" to an empty string' do
			expect( build_env( { 'SCRIPT_NAME' => '/' } )['SCRIPT_NAME'] ).to eq ''
		end

		it 'keeps other SCRIPT_NAME values' do
			expect( build_env['SCRIPT_NAME'] ).to eq '/diary/index.fcgi'
		end

		it 'defaults QUERY_STRING to an empty string' do
			env = fcgi_env
			env.delete( 'QUERY_STRING' )
			expect( described_class.build_env( env, StringIO.new, StringIO.new )['QUERY_STRING'] ).to eq ''
		end

		it 'does not mutate the original env hash' do
			original = fcgi_env( 'HTTP_CONTENT_LENGTH' => '12' )
			described_class.build_env( original, StringIO.new, StringIO.new )
			expect( original['HTTP_CONTENT_LENGTH'] ).to eq '12'
			expect( original ).not_to have_key 'rack.input'
		end

		describe 'rack.url_scheme' do
			it 'is http by default' do
				expect( build_env['rack.url_scheme'] ).to eq 'http'
			end

			%w(on yes 1).each do |value|
				it "is https when HTTPS=#{value}" do
					expect( build_env( { 'HTTPS' => value } )['rack.url_scheme'] ).to eq 'https'
				end
			end

			it 'is https when X-Forwarded-Proto says https' do
				expect( build_env( { 'HTTP_X_FORWARDED_PROTO' => 'https' } )['rack.url_scheme'] ).to eq 'https'
			end

			it 'is http when X-Forwarded-Proto says http' do
				expect( build_env( { 'HTTP_X_FORWARDED_PROTO' => 'http' } )['rack.url_scheme'] ).to eq 'http'
			end
		end
	end

	describe '.write_response' do
		def write_response( status, headers, body )
			out = StringIO.new
			described_class.write_response( out, status, headers, body )
			out.string
		end

		it 'writes the Status line, headers, a blank line and the body with CRLF' do
			response = write_response( 200, { 'content-type' => 'text/html' }, ['<html>', '</html>'] )
			expect( response ).to eq "Status: 200\r\ncontent-type: text/html\r\n\r\n<html></html>"
		end

		it 'expands Array header values into one line each' do
			response = write_response( 200, { 'set-cookie' => ['a=1; path=/', 'b=2; path=/'] }, [] )
			expect( response ).to include "set-cookie: a=1; path=/\r\nset-cookie: b=2; path=/\r\n"
		end

		it 'splits String header values containing newlines' do
			response = write_response( 200, { 'set-cookie' => "a=1\nb=2" }, [] )
			expect( response ).to include "set-cookie: a=1\r\nset-cookie: b=2\r\n"
		end

		it 'closes the body when it responds to close' do
			body = Class.new do
				def each; yield 'x'; end
				def close; @closed = true; end
				def closed?; @closed; end
			end.new
			described_class.write_response( StringIO.new, 200, {}, body )
			expect( body ).to be_closed
		end
	end

	describe '.run' do
		it 'dispatches the built env and writes the response to the request' do
			request = MockFCGIRequest.new( fcgi_env, body: 'comment=hello' )
			captured = nil
			dispatcher = lambda do |env|
				captured = env
				[200, { 'content-type' => 'text/plain' }, ['hello']]
			end

			described_class.run( request, dispatcher )

			expect( captured['tdiary.cgi_hosting'] ).to be true
			expect( captured['rack.input'].read ).to eq 'comment=hello'
			expect( request.out.string ).to eq "Status: 200\r\ncontent-type: text/plain\r\n\r\nhello"
			expect( request ).to be_finished
		end

		it 'writes a 500 response and finishes the request when dispatch raises' do
			request = MockFCGIRequest.new( fcgi_env )
			dispatcher = lambda {|env| raise 'boom' }

			described_class.run( request, dispatcher )

			expect( request.out.string ).to start_with "Status: 500\r\n"
			expect( request.out.string ).to include 'boom'
			expect( request ).to be_finished
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
