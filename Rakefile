# -*- coding: utf-8 -*-

require File.expand_path('../tdiary/environment', __FILE__)

require 'rake'
require 'rake/clean'

CLEAN.include(
	"tmp",
	"data",
	"index.rdf"
)
CLOBBER.include(
	"rdoc",
	"coverage"
)

Dir['tdiary/tasks/**/*.rake'].each {|f| load f}

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
