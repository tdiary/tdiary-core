# -*- ruby -*-

require 'rubygems'
require 'hoe'

require 'find'

base_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(base_dir, 'lib'))
require 'hikidoc'

truncate_base_dir = Proc.new do |x|
  x.gsub(/\A#{Regexp.escape(base_dir + File::SEPARATOR)}/, '')
end

manifest = File.join(base_dir, "Manifest.txt")
manifest_contents = []
base_dir_included_components = %w(COPYING README README.ja Rakefile
                                  TextFormattingRules TextFormattingRules.ja
                                  NEWS.ja setup.rb)
excluded_components = %w(.svn doc log pkg)
Find.find(base_dir) do |target|
  target = truncate_base_dir[target]
  components = target.split(File::SEPARATOR)
  if components.size == 1 and !File.directory?(target)
    next unless base_dir_included_components.include?(components[0])
  end
  Find.prune if (excluded_components - components) != excluded_components
  manifest_contents << target if File.file?(target)
end

File.open(manifest, "w") do |f|
  f.puts manifest_contents.sort.join("\n")
end
at_exit do
  FileUtils.rm_f(manifest)
end

ENV["VERSION"] ||= HikiDoc::VERSION
project = Hoe.spec('hikidoc') do |project|
  project.version = HikiDoc::VERSION
  project.author = ['Kazuhiko']
  project.email = ['kazuhiko@fdiary.net']
  project.description = project.paragraphs_of('README', 2).join
  project.summary = project.description.split(/(\.)/, 3)[0, 2].join
  project.url = 'http://rubyforge.org/projects/hikidoc/'
  project.test_globs = ['test/test_*.rb']
  project.extra_rdoc_files = %w(README COPYING NEWS TextFormattingRules)
  project.changes = File.read("NEWS").split(/^!! .*$/)[1].strip
end

desc 'Tag the repository for release.'
task :tag do
  version = HikiDoc::VERSION
  message = "Released HikiDoc #{version}!"
  base = "svn+ssh://rubyforge.org/var/svn/hikidoc/"
  sh 'svn', 'copy', '-m', message, "#{base}trunk", "#{base}tags/#{version}"
end


# Fix Hoe's uncustomizable options
rdoc_main = "lib/hikidoc.rb"
project.spec.rdoc_options.each do |option|
  option.replace(rdoc_main) if option == "README.txt"
end
ObjectSpace.each_object(Rake::RDocTask) do |task|
  task.main = rdoc_main if task.main == "README.txt"
end
