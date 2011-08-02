# coding: utf-8

require 'pit'
config = Pit.get('tdiary', :require => {
    :username => 'your username',
    :server => 'your server address'
  })

set :application, 'tdiary'

set :scm, :git
set :repository, 'git://github.com/tdiary/tdiary-core.git'
set :branch, 'master'
set :deploy_via, :remote_cache

server config[:server], :app

set :user, config[:username]
set :deploy_to, defer { "/home/#{user}/app/#{application}" }
set :password, defer { Capistrano::CLI.password_prompt('sudo password: ') }
set :use_sudo, true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc 'update shared library'
  task :update_library, :roles => :app do
    run "cp -r #{shared_path}/lib/* #{latest_release}/misc/lib"
    run "cp -r #{shared_path}/js/* #{latest_release}/js"
  end

  after 'deploy:finalize_update', 'deploy:update_library'
  after 'deploy:update', 'deploy:cleanup'
end

namespace :httpd do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :app do
      invoke_command "/etc/init.d/apache2 #{action.to_s}", :via => run_method
    end
  end
end
