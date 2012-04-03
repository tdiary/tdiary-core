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

unless ENV['RACK_ENV'] == 'production'
	Bundler.require :test
	require 'rspec/core/rake_task'
	require 'rake/testtask'
	require 'ci/reporter/rake/rspec'
	require 'ci/reporter/rake/test_unit'

	task :default => [:spec, :test]

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

		namespace :acceptance do
			desc 'Run the code examples in spec/acceptance with cgi mode'
			task :cgi do
				ENV['TEST_MODE'] = 'webrick'
				Rake::Task["spec:acceptance"].invoke
			end

			desc 'Run the code examples in spec/acceptance with secure mode'
			task :secure do
				ENV['TEST_MODE'] = 'secure'
				Rake::Task["spec:acceptance"].invoke
			end
		end

		if defined?(Rcov)
			desc 'Run the code in specs with RCov'
			RSpec::Core::RakeTask.new(:report) do |t|
				t.pattern = "spec/**/*_spec.rb"
				t.rcov = true
				t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
			end
		else
			desc 'Displayed code coverage with SimpleCov'
			task :report do
				ENV['COVERAGE'] = 'simplecov'
				Rake::Task["spec"].invoke
			end
		end
	end

	Rake::TestTask.new do |t|
		t.libs << "test"
		t.test_files = FileList['test/**/*_test.rb']
		t.verbose = true
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

desc "generate document files"
task :doc do
	require 'redcarpet'
	require 'pathname'
	Dir.glob(File.dirname(__FILE__) + "/doc/*.md") do |md|
		target = Pathname.new(md)
		header = <<-HEADER
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="ja-JP">
<head>
<title>#{target.basename('.md')}</title>
</head>
<body>
HEADER
		footer = <<-FOOTER
</body>
</html>
FOOTER
		html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true).render(File.open(md).read)
		open(target.sub(/\.md\z/, ''), 'w') {|f| f.write(header + html + footer)}
	end
end

desc "compile coffeescript"
task :compile do
	require 'coffee-script'
	FileList['js/**/*.coffee'].each do |coffee|
		File.open(coffee.sub(/\.coffee\z/, '.js'), 'w') do |js|
			js.write CoffeeScript.compile(File.read(coffee))
		end
	end
end

if ENV['DATABASE_URL']
	desc "create database"
	namespace :db do
		task :create do
			Sequel.connect(ENV['DATABASE_URL']) do |db|
				db.create_table :diaries do
					String :diary_id, :size => 8
					String :year, :size => 4
					String :month, :size => 2
					String :day, :size => 2
					String :title, :text => true
					String :body, :text => true
					String :style, :text => true
					Fixnum :last_modified
					TrueClass :visible
					primary_key :diary_id
				end

				db.create_table :comments do
					String :diary_id, :size => 8
					Fixnum :no
					String :name, :text => true
					String :mail, :text => true
					String :comment, :text => true
					Fixnum :last_modified
					TrueClass :visible
					primary_key [:diary_id, :no]
				end

				db.create_table :conf do
					String :body, :text => true
				end
			end
		end

		task :drop do
			Sequel.connect(ENV['DATABASE_URL']) do |db|
				db.drop_table :diaries, :comments, :conf
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
