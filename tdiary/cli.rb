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
		def new(name)
			target = File.join(Dir.pwd, name)
			empty_directory(target)
			empty_directory(File.join(target, 'public'))
			%w(README.md Gemfile config.ru tdiary.conf.beginner
				tdiary.conf.sample tdiary.conf.sample-en).each do |file|
				copy_file(file, File.join(target, file))
			end
			copy_file('tdiary.conf.beginner', File.join(target, 'tdiary.conf'))
			directory('doc', File.join(target, 'doc'))
			inside(target) do
				run('bundle install --without test development')
			end
		end

		desc "version", "Prints the tDiary's version information"
		def version
			say "tdiary #{TDiary::VERSION}"
		end
		map %w(-v --version) => :version
	end
end
