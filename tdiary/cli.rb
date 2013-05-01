# coding: utf-8
require 'thor'
require 'tdiary'

module TDiary
	class CLI < Thor
		include Thor::Actions

		desc "version", "Prints the tDiary's version information"
		def version
			say "tdiary #{TDiary::VERSION}"
		end
		map %w(-v --version) => :version
	end
end
