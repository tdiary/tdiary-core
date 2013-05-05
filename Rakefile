# -*- coding: utf-8 -*-

%w(tdiary/environment tdiary/tasks).each do |file|
	begin
		# in tDiary gem environment
		require file
	rescue LoadError
		# in local environment
		require File.expand_path("../#{file}", __FILE__)
	end
end

require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks' if File.exists?('tdiary.gemspec')

CLEAN.include(
	"tmp",
	"data",
	"index.rdf"
)
CLOBBER.include(
	"rdoc",
	"coverage"
)

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
