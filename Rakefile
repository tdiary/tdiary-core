# -*- coding: utf-8 -*-

begin
	# for using tDiary gem
	require 'tdiary/environment'
rescue LoadError
	require File.expand_path('../tdiary/environment', __FILE__)
end

begin
	# for using tDiary gem
	require 'tdiary/tasks'
rescue LoadError
	require File.expand_path('../tdiary/tasks', __FILE__)
end

require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'

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
