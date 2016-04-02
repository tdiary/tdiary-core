$LOAD_PATH.unshift 'lib'

require 'tdiary/environment'
require 'tdiary/tasks'

require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks' if File.exist?('tdiary.gemspec')

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
