# coding: utf-8
require 'thor'
require 'tdiary'

module TDiary
	class CLI < Thor
		include Thor::Actions

		def self.source_root
			TDiary.root
		end

		desc "new DIR_NAME", "Create a new tDiary directory"
		method_option "spec", :type => :string, :banner => "install with test files"
		def new(name)
			target = File.join(Dir.pwd, name)

			empty_directory(target)
			empty_directory(File.join(target, 'public'))
			empty_directory(File.join(target, 'misc/plugin'))
			%w(
				README.md
				Gemfile
				Rakefile
				config.ru
				tdiary.conf.beginner
				tdiary.conf.sample
				tdiary.conf.sample-en
			).each do |file|
				copy_file(file, File.join(target, file))
			end
			copy_file('tdiary.conf.beginner', File.join(target, 'tdiary.conf'))
			directory('doc', File.join(target, 'doc'))
			if options[:spec]
				append_to_file(File.join(target, 'Gemfile'), "path '#{TDiary.root}'")
				directory('spec', File.join(target, 'spec'))
				directory('test', File.join(target, 'test'))
			end

			Bundler.with_clean_env do
				inside(target) do
					if options[:spec]
						# run('bundle install --without development')
						run('bundle install')
					else
						run('bundle install --without test development')
						run('bundle exec tdiary htpasswd')
					end
				end
			end
			say 'install finished', :green
			say "run `tdiary server` in #{name} directory to start server", :green
		end

		desc "server", "Start tDiary server"
		def server
			run 'bundle exec rackup'
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
	end
end
