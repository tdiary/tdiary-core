#
# Ralefile for releasing tDiary.
#

STABLE = '3.1.4'
REPOS = %w(core theme blogkit contrib)

DEST_DIR = "/var/www/tdiary.org/htdocs/download"
TARBALLS = []

#
# utilities
#
def fetch_files( repo )
	rm_rf repo rescue true
	sh "git clone --depth 1 git://github.com/tdiary/tdiary-#{repo}.git #{repo}"
end

REPOS.each_with_index do |repo, i|
	file REPOS[i] {|t| fetch_files( t.name )}
end

def make_tarball( repo, version = nil )
	suffix = version ? "-#{version}" : ''
	dest = "tdiary#{repo == 'core' ? '' : "-#{repo}"}#{suffix}"

	if version then
		Dir.chdir repo do
			sh "git checkout #{version}"
		end
	end
	rm_rf "#{repo}/.git"

	sh "find #{repo} -type f | xargs chmod 644"
	sh "find #{repo} -type d | xargs chmod 755"

	if repo == 'core' then
		Dir.chdir 'core' do
			sh "chmod +x index.rb update.rb"
			sh 'bundle install --path ../bundle'
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

desc 'making packages of snapshot.'
task :snapshot => REPOS do
	TARBALLS.clear
	REPOS.each do |repo|
		make_tarball( repo )
	end
	Dir["theme/*"].each do |d|
		mv d, "core/theme/"
	end
	mv "core", "tdiary"
	sh "tar zcf tdiary-full.tar.gz tdiary"
	mv "tdiary", "core"
	TARBALLS << "tdiary-full.tar.gz"
end

desc 'making packages of stable.'
task :stable => REPOS do
	TARBALLS.clear
	REPOS.each do |repo|
		make_tarball( repo, STABLE )
	end
	Dir["theme/*"].each do |d|
		mv d, "core/theme/" rescue true
	end
	rmdir "theme"
	mv "core", "tdiary-#{STABLE}"
	sh "tar zcf tdiary-full-#{STABLE}.tar.gz tdiary-#{STABLE}"
	mv "tdiary-#{STABLE}", "core"
	TARBALLS << "tdiary-full-#{STABLE}.tar.gz"
end

desc 'cleanup all files.'
task :clean do
	REPOS.each do |repo|
		rm_rf repo rescue true
	end
	sh "rm *.tar.gz" rescue true
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
