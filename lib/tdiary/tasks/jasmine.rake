begin
	require 'jasmine'
	load 'jasmine/tasks/jasmine.rake'
rescue LoadError
	task :jasmine do
		abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
