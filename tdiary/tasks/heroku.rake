namespace :heroku do
	file 'tdiary.conf' => ['tdiary.conf.heroku'] do |t|
		FileUtils.cp(t.prerequisites.first, t.name)
	end

	file '.htpasswd' do
		Rake::Task["auth:password:create"].invoke
	end

	task :install => ['.htpasswd', 'tdiary.conf'] do |t|
		sh "git checkout -b deploy"
		sh "git add -f #{t.prerequisites.join(' ')}"
		sh "git commit -m 'deploy'"
		sh "git push heroku deploy:master"
		# FIXME: heroku command does not work in rake env
		# sh "heroku run rake db:create"
	end

	task :update do
		# sh "git pull origin master:deploy"
		# sh "git push heroku deploy:master"
		raise NotImplementedError
	end

	task :clean do
		sh "git checkout master"
		sh "git branch -D deploy"
	end
end
