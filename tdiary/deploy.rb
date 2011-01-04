set :application, "tdiary-core"
set :repository, File.expand_path('../..', __FILE__)

set :user, "user"
set(:home) { "/home/#{user}" }
set(:deploy_to) { "#{home}/app/tdiary-core" }
set :scm, :git
set :branch, 'master'
set :deploy_via, :copy

role :app, "server"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
end
