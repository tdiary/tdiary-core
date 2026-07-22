#
# Rakefile for building tDiary release tarballs.
#
STABLE = `git tag | grep -v beta | sort -r -V | head -1`.chomp
REPOS = %w(tdiary-core tdiary-theme tdiary-blogkit tdiary-contrib)

TARBALLS = []

def fetch_files( repo )
	Dir.chdir("tmp") do
		rm_rf repo rescue true
		sh "git clone https://github.com/tdiary/#{repo}.git #{repo}"
	end
end

# Check out the release tag in a cloned repo. Sibling repos are not always
# tagged for core-only patch releases, so fall back to the latest tag of the
# same minor series, then to the default branch as cloned.
def checkout_release( repo, version )
	Dir.chdir repo do
		tags = `git tag`.split(/\n/)
		unless tags.include?(version)
			minor = version[/\Av\d+\.\d+\./]
			version = tags.grep(/\A#{Regexp.escape(minor)}\d+(\.\d+)*\z/).max_by {|t| Gem::Version.new(t.sub(/\Av/, '')) } if minor
		end
		if version && tags.include?(version)
			sh "git checkout #{version}"
		else
			puts "#{repo}: no matching tag, using default branch"
		end
	end
end

# Gems that ship a C extension but also provide a pure-ruby implementation,
# so we can vendor the .rb files and drop the compiled extension.
NATIVE_GEMS_WITH_RUBY_FALLBACK = %w(cgi)

# Build a self-contained vendor/bundle for the full tarball.
#
# Only pure-ruby gems are vendored, into a single flat gem repository
# (vendor/bundle/{gems,specifications}) that every supported Ruby shares.
# Native gems are not copied across ABIs: date is a Ruby default gem, and
# cgi is vendored without its compiled escape extension (pure-ruby fallback).
def vendor_pure_ruby_gems
	build_dir = File.expand_path('.vendor-build')
	vendor = File.expand_path('vendor/bundle')
	rm_rf build_dir
	rm_rf vendor
	mkdir_p "#{vendor}/gems"
	mkdir_p "#{vendor}/specifications"

	Bundler.with_unbundled_env do
		ENV['BUNDLE_PATH'] = build_dir
		ENV['BUNDLE_WITHOUT'] = 'development:test'
		ENV['BUNDLE_FROZEN'] = 'true'
		sh 'bundle install'
	end

	abi = Dir["#{build_dir}/ruby/*"].first
	Dir["#{abi}/specifications/*.gemspec"].each do |spec_file|
		spec = Gem::Specification.load(spec_file)
		next if spec.nil?
		name_version = "#{spec.name}-#{spec.version}"
		gem_dir = "#{abi}/gems/#{name_version}"
		if spec.extensions.empty?
			cp_r gem_dir, "#{vendor}/gems/#{name_version}"
			cp spec_file, "#{vendor}/specifications/"
		elsif NATIVE_GEMS_WITH_RUBY_FALLBACK.include?(spec.name)
			cp_r gem_dir, "#{vendor}/gems/#{name_version}"
			# bundle install compiles the extension into lib; drop the ABI-specific
			# artifacts so only the pure-ruby fallback is shipped
			Dir["#{vendor}/gems/#{name_version}/**/*.{so,bundle,dll,o}"].each {|f| rm_f f }
			spec.extensions.clear
			File.write("#{vendor}/specifications/#{File.basename(spec_file)}", spec.to_ruby)
			puts "vendored without native extension: #{name_version}"
		else
			puts "skipped native gem (provided at deploy time): #{name_version}"
		end
	end
	rm_rf build_dir

	# reduce filesize: keep only lib/ and data/ in each vendored gem
	Dir["#{vendor}/gems/*/*/"].each do |dir|
		rm_rf dir unless %w(lib data).include?(File.basename(dir))
	end

	# Ship a bundler config that excludes dev/test but sets no path, so
	# bundler/setup resolves the vendored gems from GEM_PATH at runtime.
	mkdir_p '.bundle'
	File.write('.bundle/config', %Q(---\nBUNDLE_WITHOUT: "development:test"\n))
end

def make_tarball( repo, version = nil )
	suffix = version ? "-#{version}" : '-snapshot'
	dest = "#{repo == 'tdiary-core' ? 'tdiary' : repo}#{suffix}"

	checkout_release( repo, version ) if version
	rm_rf "#{repo}/.git"

	sh "find #{repo} -type f | xargs chmod 644"
	sh "find #{repo} -type d | xargs chmod 755"

	if repo == 'tdiary-core' then
		Dir.chdir 'tdiary-core' do
			sh "chmod +x index.rb index.fcgi update.rb update.fcgi"
			sh 'rake doc'
			vendor_pure_ruby_gems
		end
	end

	mv repo, dest
	sh "tar zcf #{dest}.tar.gz --format=posix #{dest}"
	mv dest, repo
	TARBALLS << "#{dest}.tar.gz"
end

def make_full_package(version = nil)
	suffix = version ? "-#{version}" : '-snapshot'
	Dir.chdir("tmp") do
		TARBALLS.clear
		REPOS.each do |repo|
			make_tarball( repo, version )
		end
		Dir["tdiary-theme/*"].each do |d|
			mv d, "tdiary-core/theme/" rescue true
		end
		mv "tdiary-core", "tdiary#{suffix}"
		sh "tar zcf tdiary-full#{suffix}.tar.gz --format=posix tdiary#{suffix}"
		TARBALLS << "tdiary-full#{suffix}.tar.gz"
		rm_rf "tdiary#{suffix}"
		REPOS.each {|repo| rm_rf repo rescue true }
	end
end

namespace :package do
	desc 'fetching all files from GitHub.'
	task :fetch do
		REPOS.each{|r| fetch_files(r) }
	end

	desc 'making packages of snapshot.'
	task :snapshot => :fetch do
		make_full_package
	end

	desc 'making packages of stable. VERSION=vX.Y.Z overrides the latest tag.'
	task :stable => :fetch do
		make_full_package(ENV['VERSION'] || STABLE)
	end

	desc 'cleanup all files.'
	task :clean do
		Dir.chdir("tmp") do
			REPOS.each {|repo| rm_rf repo rescue true }
			sh "rm *.tar.gz" rescue true
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
