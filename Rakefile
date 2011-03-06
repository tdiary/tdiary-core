require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rspec/core/rake_task'

CLEAN.include(
	"tmp",
	"coverage.aggregate",
	"data",
	"index.rdf",
	"*.html"
)
CLOBBER.include(
	"rdoc",
	"coverage"
)

task :default => [:spec, :test]

desc "Run specs"
task :spec do |t|
	Rake::Task["spec:all"].invoke
end

namespace :spec do
	desc 'Run the code in spec'
	RSpec::Core::RakeTask.new(:all) do |t|
		t.pattern = "spec/**/*_spec.rb"
	end

	%w(core plugin acceptance).each do |dir|
		desc "Rub the code examples in spec/#{dir}"
		RSpec::Core::RakeTask.new(dir.to_sym) do |t|
			t.pattern = "spec/#{dir}/**/*_spec.rb"
		end
	end

	desc 'Run specs w/ RCov'
	RSpec::Core::RakeTask.new(:rcov) do |t|
		t.pattern = "spec/**/*_spec.rb"
		t.rcov = true
		t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
	end
	task :rcov => "coverage:clean"
end

namespace :coverage do
	desc "delete aggregate coverage data"
	task(:clean) {
		rm_f "coverage/*"
		mkdir "coverage" unless File.exist? "coverage"
		rm "coverage.aggregate" if File.exist? "coverage.aggregate"
	}
end

Rake::TestTask.new do |t|
	t.libs << "test"
	t.test_files = FileList['test/*_test.rb']
	t.verbose = true
end

desc "all coverage"
task :coverage => ["coverage:clean", "spec:rcov"]

desc "generate rdoc files"
task :docs do
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
