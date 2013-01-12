# -*- mode: ruby; coding: utf-8 -*-
require 'rubygems'
require 'rake'
require 'rake/packagetask'
require 'rake/testtask'
require 'rake/clean'
require 'date' unless defined? Date

#############################################################################
#  Helper functions
#############################################################################
def name
  @name  ||= Dir['*.gemspec'].first.split('.').first
end

def version
  require './lib/rd/version.rb'
  RD::VERSION
end

def date
  Date.today.to_s
end

def rubyforge_project
  name
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end

# src files for parser and html documents
RACC_SRC = FileList['lib/rd/*.ry']
RACC_GENERATED = RACC_SRC.ext('.tab.rb')
HTML_SRC = FileList['**/*.rd'].reject{|f| f =~/pkg/}
HTML_GENERATED = HTML_SRC.ext('.html')
HTML_JA_SRC = FileList['**/*.rd.ja'].reject{|f| f =~/pkg/}
HTML_JA_GENERATED = HTML_JA_SRC.collect{|x| x.gsub(/\.rd\.ja/,'.ja.html')}
GENERATED_FILES = RACC_GENERATED + HTML_GENERATED + HTML_JA_GENERATED
CLOBBER.push GENERATED_FILES

desc "Update parser"
task :racc => RACC_GENERATED
RACC_SRC.each do |f|
  file f.ext('.tab.rb') => f do |t|
    sh "racc -o #{t.name} #{t.prerequisites[0]}"
  end
end
desc "Update html files"
task :doc => [:racc, :html, :html_ja]
task :html => HTML_GENERATED
HTML_SRC.each do |f|
  file f.ext('.html') => f do |t|
    sh "ruby -Ilib bin/rd2 #{t.prerequisites[0]} > #{t.name}"
  end
end
task :html_ja => HTML_JA_GENERATED
HTML_JA_SRC.each do |f|
  file f.gsub(/\.rd\.ja/,'.ja.html') => f do |t|
    sh "ruby -Ilib bin/rd2 #{t.prerequisites[0]} > #{t.name}"
  end
end

task :default => :test
desc "=> clobber"
task :distclean => :clobber

task :test => :racc
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test-*.rb']
  t.verbose = true
end

desc "Create tag v#{version} and build and push #{gem_file} to Rubygems"
task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
  sh "gem push pkg/#{name}-#{version}.gem"
end

desc "Generate #{gem_file}"
task :build => [:gemspec, :package] do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg/"
end

desc "Update #{gemspec_file}"
task :gemspec => [:racc, :doc, :bump_version] do
  unless File.read('HISTORY') =~ /#{version}/
    puts "Update HISTORY!!"
    exit!
  end
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")
  replace_header(head, :name)
  replace_header(head, :version)
  replace_header(head, :date)
  # replace_header(head, :rubyforge_project)
  files = (`git ls-files`.split("\n") + GENERATED_FILES.to_a).
    sort.
    reject {|file| file =~/^\./}.
    reject {|file| file =~/^(rdoc|pkg)/}.
    map {|file| "    #{file}" }.
    join("\n")
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w'){ |io| io.write(spec)}
  puts "Update #{gemspec_file}"
end

Rake::PackageTask.new("rdtool", "#{version}") do |t|
  t.need_tar_gz = true
  t.package_files.include GENERATED_FILES
  t.package_files.include('lib/**/*')
  t.package_files.include('README*')
  t.package_files.include('bin/*')
  t.package_files.include('doc/*')
  t.package_files.include('utils')
  t.package_files.include('*.txt')
  t.package_files.include('LGPL-2.1')
  t.package_files.include('HISTORY')
  t.package_files.include('setup.rb')
end

desc "Update/Sync RD::VERSION"
task :bump_version do
  FileList['README*'].each do |path|
    #path = File.expand_path(path)
    orig = IO.read(path)
    after = orig.sub(/(^=\sRDtool\s)\d+\.\d+\.\d+$/, '\1' + version)
    unless after == orig
      File.open(path, 'wb'){|f| f.write after }
    end
  end
end
