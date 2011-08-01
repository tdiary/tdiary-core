# -*- coding: utf-8 -*-

require File.expand_path('../tdiary/environment', __FILE__)
require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include(
	"tmp",
	"coverage.aggregate",
	"coverage.data",
	"data",
	"index.rdf"
)
CLOBBER.include(
	"rdoc",
	"coverage"
)

task :default => [:spec]

desc 'Run the code in spec'
RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
	%w(core plugin acceptance).each do |dir|
		desc "Run the code examples in spec/#{dir}"
		RSpec::Core::RakeTask.new(dir.to_sym) do |t|
			t.pattern = "spec/#{dir}/**/*_spec.rb"
		end
	end

	if RUBY_VERSION < '1.9'
		desc 'Run the code in specs with RCov'
		RSpec::Core::RakeTask.new(:report) do |t|
			t.pattern = "spec/**/*_spec.rb"
			t.rcov = true
			t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
		end
	else
		desc 'Displayed code coverage with cover_me'
		task :report do
			require 'cover_me'
			CoverMe.config do |c|
				c.project.root = File.dirname(__FILE__)
				c.file_pattern = /(#{CoverMe.config.project.root}\/tdiary.*\.rb)/i
			end
			CoverMe.complete!
		end
	end
end

desc "generate rdoc files"
task :rdoc do
	root_dir = File.dirname(__FILE__)

	dirlist = Dir.glob(root_dir + "/rdoc/**/").sort {
		|a,b| b.split('/').size <=> a.split('/').size
	}
	dirlist.each {|d|
		Dir.foreach(d) {|f|
			File::delete(d + f) if !(/\.+$/ =~ f)
		}
		Dir.rmdir(d)
	}

	`cd #{root_dir} && rdoc --all --charset=UTF8 --op=rdoc --inline-source README ChangeLog index.rb update.rb tdiary.rb tdiary/* misc/* plugin/*`
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
