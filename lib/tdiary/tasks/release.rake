#
# Ralefile for releasing tDiary.
#

STABLE = `git tag | sort -r | head -1`.chomp
REPOS = %w(tdiary-core tdiary-theme tdiary-blogkit tdiary-contrib)

DEST_DIR = "/var/www/tdiary.org/htdocs/download"
TARBALLS = []

def fetch_files( repo )
	Dir.chdir("tmp") do
		rm_rf repo rescue true
		sh "git clone --depth 10 https://github.com/tdiary/#{repo}.git #{repo}"
	end
end

def make_tarball( repo, version = nil )
	suffix = version ? "-#{version}" : '-snapshot'
	dest = "#{repo == 'tdiary-core' ? 'tdiary' : repo}#{suffix}"

	if version then
		Dir.chdir repo do
			sh "git checkout #{version}"
		end
	end
	rm_rf "#{repo}/.git"

	sh "find #{repo} -type f | xargs chmod 644"
	sh "find #{repo} -type d | xargs chmod 755"

	if repo == 'tdiary-core' then
		Dir.chdir 'tdiary-core' do
			sh "chmod +x index.rb index.fcgi update.rb update.fcgi"
			sh 'rake doc'
			Bundler.with_clean_env do
					sh "bundle --path .bundle --without coffee:server:development:test"
			end
			Dir.chdir '.bundle/ruby' do
				v = `ls`.chomp
				case v
				when '2.1.0'
					FileUtils.cp_r '2.1.0', '1.9.1'
					FileUtils.cp_r '2.1.0', '2.0.0'
				when '2.0.0'
					FileUtils.cp_r '2.0.0', '1.9.1'
					FileUtils.cp_r '2.0.0', '2.1.0'
				when '1.9.1'
					FileUtils.cp_r '1.9.1', '2.0.0'
					FileUtils.cp_r '1.9.1', '2.1.0'
				else
					FileUtils.cp_r v, '2.1.0'
					FileUtils.cp_r v, '2.0.0'
					FileUtils.cp_r v, '1.9.1'
					FileUtils.rm_rf v
				end
			end
			Dir.chdir 'misc/lib' do
				sh 'gem unpack bundler'
			end
		end
	end

	mv repo, dest
	sh "tar zcf #{dest}.tar.gz #{dest}"
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
		sh "tar zcf tdiary-full#{suffix}.tar.gz tdiary#{suffix}"
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

	desc 'releasing all files'
	task :release do
		Dir.chdir("tmp") do
			TARBALLS = Dir["*.tar.gz"] if TARBALLS.empty?
			TARBALLS.each do |tgz|
				sh "scp -P 443 #{tgz} www.tdiary.org:#{DEST_DIR}"
			end
		end
	end

	desc 'making packages of snapshot.'
	task :snapshot => :fetch do
		make_full_package
	end

	desc 'making packages of stable.'
	task :stable => :fetch do
		make_full_package(STABLE)
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
