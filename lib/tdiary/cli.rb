# coding: utf-8
require 'thor'
require 'tdiary/version'
require 'bundler'

module TDiary
	class CLI < Thor
		include Thor::Actions

		def self.source_root
			File.expand_path('../../..', __FILE__)
		end

		desc "new DIR_NAME", "Create a new tDiary directory"
		method_option "skip-bundle", type: :boolean, banner:
			"don't run bundle and .htpasswd generation"
		def new(name)
			target = File.join(Dir.pwd, name)
			deploy(target)
			copy_file('tdiary.conf.beginner', File.join(target, 'tdiary.conf'))
			template('misc/templates/Gemfile.erb', File.join(target, 'Gemfile'))

			unless options[:'skip-bundle']
				Bundler.with_clean_env do
					inside(target) do
						run('bundle install --without test development')
						run('bundle exec tdiary htpasswd')
					end
				end
			else
				say "run `bundle install && bundle exec tdiary htpasswd` manually", :red
			end
			say 'install finished', :green
			say "run `tdiary server` in #{name} directory to start server", :green
		end

		desc "update", "update tDiary"
		method_option "skip-bundle", type: :boolean, banner:
			"don't run bundle"
		def update
			target = Dir.pwd
			unless in_tdiary_dir?(target)
				say "please run update command in your tdiary directory", :red
				return 1
			end

			deploy(target)

			unless options[:'skip-bundle']
				Bundler.with_clean_env do
					inside(target) do
						run('bundle install --without test development')
					end
				end
			end
			say 'update finished', :green
		end

		desc "assets_copy", "copy assets files"
		def assets_copy
			require 'tdiary'
			assets_path = File.join(TDiary.server_root, 'public/assets')
			TDiary::Application.config.assets_paths.each do |path|
				Dir.glob(File.join(path, '*')).each do |entity|
					if File.directory?(entity)
						directory entity, File.join(assets_path, File.basename(entity))
					else
						copy_file entity, File.join(assets_path, File.basename(entity))
					end
				end
			end
		end

		desc "test", "Create test server and run tDiary test"
		def test
			target = File.join(Dir.pwd, 'tmp/test')
			deploy(target)
			copy_file('Gemfile', File.join(target, 'Gemfile'))
			gsub_file(File.join(target, 'Gemfile'),
				/^gemspec$/,
				"gemspec path: '#{CLI::source_root}'"
			)
			copy_file('Rakefile', File.join(target, 'Rakefile'))
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
		method_option "rack", type: :string, banner:
			"start server with rack interface (default)"
		method_option "cgi", type: :string, banner:
			"start server with cgi interface"
		method_option "bind", aliases: "b", type: :string, default: "0.0.0.0", banner:
			"bind to the IP"
		method_option "port", aliases: "p", type: :numeric, default: 19292, banner:
			"use PORT"
		method_option "log", aliases: "l", type: :string, banner:
			"File to redirect output"
		def server
			require 'tdiary'
			require 'tdiary/environment'

			if options[:cgi]
				opts = {
					:daemon => ENV['DAEMON'],
					:bind   => options[:bind],
					:port   => options[:port],
					:logger => $stderr,
					:access_log => options[:log] ? File.open(options[:log], 'a') : $stderr
				}
				TDiary::Server.run( opts )
			elsif
				# --rack option
				# Rack::Server reads ARGV as :config, so delete it
				require 'webrick'
				ARGV.shift
				opts = {
					:environment => ENV['RACK_ENV'] || "development",
					:daemonize   => false,
					:Host        => options[:bind],
					:Port        => options[:port],
					:pid         => File.expand_path("tdiary.pid"),
					:config      => File.expand_path("config.ru")
				}
				if options[:log]
					opts[:AccessLog] = [[File.open(options[:log], 'a'), WEBrick::AccessLog::CLF]]
				end
				::Rack::Server.start( opts )
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
				empty_directory(File.join(target, 'lib/tdiary/filter'))
				empty_directory(File.join(target, 'lib/tdiary/style'))
				empty_directory(File.join(target, 'js'))
				empty_directory(File.join(target, 'theme'))
				%w(
				README.md
				config.ru
				tdiary.conf.beginner
				tdiary.conf.sample
				tdiary.conf.sample-en
				).each do |file|
					copy_file(file, File.join(target, file))
				end
				directory('doc', File.join(target, 'doc'))
			end

			def in_tdiary_dir?(target)
				File.exist?(File.join(target, 'tdiary.conf'))
			end
		end
	end
end
