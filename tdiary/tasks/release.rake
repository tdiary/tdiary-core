#
# Ralefile for releasing tDiary.
#

STABLE = `git tag | sort -r | head -1`.chomp
REPOS = %w(tdiary-core tdiary-theme tdiary-blogkit tdiary-contrib)

DEST_DIR = "/var/www/tdiary.org/htdocs/download"
TARBALLS = []

#
# utilities
#
def fetch_files( repo )
	Dir.chdir("tmp") do
		rm_rf repo rescue true
		sh "git clone git://github.com/tdiary/#{repo}.git #{repo}"
	end
end

REPOS.each_with_index do |repo, i|
	file REPOS[i] do |t|
		fetch_files(t.name)
	end
end

def make_tarball( repo, version = nil )
	suffix = version ? "-#{version}" : ''
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
		end
	end

	mv repo, dest
	sh "tar zcf #{dest}.tar.gz #{dest}"
	mv dest, repo
	TARBALLS << "#{dest}.tar.gz"
end

#
# tasks
#
task :default => :snapshot

desc 'fetching all files from GitHub.'
task :fetch => REPOS

desc 'releasing all files'
task :release do
	Dir.chdir("tmp") do
		TARBALLS = Dir["*.tar.gz"] if TARBALLS.empty?
		TARBALLS.each do |tgz|
			sh "scp #{tgz} -P 443 www.tdiar.org:#{DIST_DIR}"
		end
	end
end

desc 'making packages of snapshot.'
task :snapshot => REPOS do
	Dir.chdir("tmp") do
		TARBALLS.clear
		REPOS.each do |repo|
			make_tarball( repo )
		end
		Dir["tdiary-theme/*"].each do |d|
			mv d, "tdiary-core/theme/"
		end
		mv "tdiary-core", "tdiary"
		sh "tar zcf tdiary-full.tar.gz tdiary"
		TARBALLS << "tdiary-full.tar.gz"
		rm_rf "tdiary"
		REPOS.each {|repo| rm_rf repo rescue true }
	end
end

desc 'making packages of stable.'
task :stable => REPOS do
	Dir.chdir("tmp") do
		TARBALLS.clear
		REPOS.each do |repo|
			make_tarball( repo, STABLE )
		end
		Dir["tdiary-theme/*"].each do |d|
			mv d, "tdiary-core/theme/" rescue true
		end
		mv "tdiary-core", "tdiary-#{STABLE}"
		sh "tar zcf tdiary-full-#{STABLE}.tar.gz tdiary-#{STABLE}"
		TARBALLS << "tdiary-full-#{STABLE}.tar.gz"
		rm_rf "tdiary-#{STABLE}"
		REPOS.each {|repo| rm_rf repo rescue true }
	end
end

desc 'cleanup all files.'
task :clean do
	Dir.chdir("tmp") do
		REPOS.each {|repo| rm_rf repo rescue true }
		sh "rm *.tar.gz" rescue true
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
