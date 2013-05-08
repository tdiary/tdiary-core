# coding: utf-8
require 'thor'
require 'tdiary'
require 'bundler'

module TDiary
	class CLI < Thor
		include Thor::Actions

		def self.source_root
			TDiary.root
		end

		desc "new DIR_NAME", "Create a new tDiary directory"
		def new(name)
			target = File.join(Dir.pwd, name)
			deploy(target)

			Bundler.with_clean_env do
				inside(target) do
					run('bundle install --without test development')
					run('bundle exec tdiary htpasswd')
				end
			end
			say 'install finished', :green
			say "run `tdiary server` in #{name} directory to start server", :green
		end

		desc "test", "Create test server and run tDiary test"
		def test
			target = File.join(Dir.pwd, 'tmp/test')
			deploy(target)
			append_to_file(File.join(target, 'Gemfile'), "path '#{TDiary.root}'")
			directory('spec', File.join(target, 'spec'))
			directory('test', File.join(target, 'test'))

			Bundler.with_clean_env do
				inside(target) do
					run('bundle install')
					run('bundle exec rake spec')
				end
			end
		end

		desc "server", "Start tDiary server"
		method_option "rack", :type => :string, :banner =>
			"start server with rack interface (default)"
		method_option "cgi", :type => :string, :banner =>
			"start server with cgi interface"
		def server
			if options[:cgi]
				opts = {
					:daemon => ENV['DAEMON'],
					:bind   => ENV['BIND'] || '0.0.0.0',
					:port   => ENV['PORT'] || 19292,
					:logger => $stderr,
					:access_log => $stderr,
				}
				TDiary::Server.run( opts )
			elsif
				# --rack option
				require 'rack'
				# Rack::Server reads ARGV as :config, so delete it
				ARGV.shift
				Rack::Server.start
			end
		end

		desc "htpasswd", "Create a .htpasswd file"
		def htpasswd
			require 'webrick/httpauth/htpasswd'
			say "Input your username/password"
			print 'Username: '
			ARGV.replace([])
			username = gets().chop
			print 'New password: '
			system "stty -echo"
			password = $stdin.gets.chop
			puts
			print 'Re-type new password: '
			password2 = $stdin.gets.chop
			puts
			system "stty echo"
			if password != password2
				raise StandardError, 'password verification error'
			end
			htpasswd = WEBrick::HTTPAuth::Htpasswd.new('.htpasswd')
			htpasswd.set_passwd(nil, username, password)
			htpasswd.flush
		end

		desc "version", "Prints the tDiary's version information"
		def version
			say "tdiary #{TDiary::VERSION}"
		end
		map %w(-v --version) => :version

		no_commands do
			def deploy(target)
				empty_directory(target)
				empty_directory(File.join(target, 'public'))
				empty_directory(File.join(target, 'misc/plugin'))
				%w(
				README.md
				Gemfile
				config.ru
				tdiary.conf.beginner
				tdiary.conf.sample
				tdiary.conf.sample-en
				).each do |file|
					copy_file(file, File.join(target, file))
				end
				copy_file('tdiary.conf.beginner', File.join(target, 'tdiary.conf'))
				directory('doc', File.join(target, 'doc'))
			end
		end
	end
end
