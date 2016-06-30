#
# Ralefile for releasing tDiary.
#
begin
	require 'octokit'

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
						sh "bundle --path .bundle --without rack:development:test"
				end

				# reduce filesize
				Dir.glob('.bundle/ruby/*/cache/*').each do |file|
					# cached gem file
					rm_rf file
				end
				Dir.glob('.bundle/ruby/*/gems/*/*/').each do |dir|
					# spec, fixtures etc..
					rm_rf dir unless File.basename(dir).match(/lib|data/)
				end

				Dir.chdir '.bundle/ruby' do
					versions = %w(2.1.0 2.2.0 2.3.0)
					current = `ls`.chomp
					versions.each {|version|
						FileUtils.cp_r current, version unless current == version
					}
					FileUtils.rm_rf current unless versions.member?(current)
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

	#
	# https://developer.github.com/v3/repos/releases/#create-a-release
	#
	def create_github_release(version)
		name = "tDiary #{version.sub(/v/, '')}"
		puts "creating github release #{version}, #{name}"
		begin
			Octokit.create_release('tdiary/tdiary-core', version, name: name)
		rescue Octokit::ClientError => e
			STDERR.puts e
		end
	end

	#
	# https://developer.github.com/v3/repos/releases/#get-a-release-by-tag-name
	#
	def find_or_create_github_release(version)
		begin
			release = Octokit.release_for_tag('tdiary/tdiary-core', version)
		rescue Octokit::NotFound
			release = create_github_release(version)
		end
		release
	end

	#
	# https://developer.github.com/v3/repos/releases/#upload-a-release-asset
	#
	def upload_github_asset(release, file)
		puts "updating file to github: #{file}"
		begin
			Octokit.upload_asset(release.url, file)
		rescue Octokit::ClientError => e
			STDERR.puts e
		end
	end

	#
	# https://developer.github.com/v3/#authentication
	#
	def login_github
		unless ENV['GITHUB_ACCESS_TOKEN']
			raise "Missing $GITHUB_ACCESS_TOKEN environment.\nSee: https://help.github.com/articles/creating-an-access-token-for-command-line-use/"
		end
		Octokit.configure {|c| c.access_token = ENV['GITHUB_ACCESS_TOKEN'] }
		Octokit.auto_paginate = true
	end

	namespace :package do
		desc 'fetching all files from GitHub.'
		task :fetch do
			REPOS.each{|r| fetch_files(r) }
		end

		desc 'releasing all files'
		task :release do
			login_github
			Dir.chdir("tmp") do
				TARBALLS = Dir["*.tar.gz"] if TARBALLS.empty?
				TARBALLS.each do |tgz|
					# TODO: v5.0.0.20160501 形式のバージョンに対応させる
					version = tgz.match(/v?\d\.\d\.\d/).to_a[0]
					next unless version
					release = find_or_create_github_release(version)
					upload_github_asset(release, tgz)
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
rescue LoadError
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
