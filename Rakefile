require 'rake'
require 'spec/rake/spectask'
require 'rake/clean'

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

task :default => :spec

desc "Run specs"
task :spec do |t|
	Rake::Task["spec:all"].invoke
end

namespace :spec do
	desc 'Run the code in spec'
	Spec::Rake::SpecTask.new(:all) do |t|
		t.spec_files = FileList["spec/**/*_spec.rb"]
		t.spec_opts << '--options' << File.join('spec', 'spec.opts')
	end

	%w(core plugin acceptance).each do |dir|
		desc "Rub the code examples in spec/#{dir}"
		Spec::Rake::SpecTask.new(dir.to_sym) do |t|
			t.spec_files = FileList["spec/#{dir}/**/*_spec.rb"]
			t.spec_opts << '--options' << File.join('spec', 'spec.opts')
		end
	end

	desc 'Run specs w/ RCov'
	Spec::Rake::SpecTask.new(:rcov) do |t|
		t.spec_files = FileList["spec/**/*_spec.rb"]
		t.spec_opts << '--options' << File.join('spec', 'spec.opts')
		t.rcov = true
		t.rcov_dir = File.expand_path("coverage/spec", File.dirname(__FILE__))
		t.rcov_opts = lambda do
			IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
		end
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

desc "all coverage"
task :coverage => ["coverage:clean","spec:rcov"]

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
