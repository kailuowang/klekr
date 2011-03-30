default_run_options[:pty] = true

require 'bundler/capistrano'

set :application, "collectr"
set :repository, "git@github.com:kailuowang/collectr.git"
set :user, "ec2-user"
set :scm, :git
set :deploy_to, '/apps/'
set :ec2_server, 'collectr.kailuowang.com'

role :web, ec2_server                          # Your HTTP server, Apache/etc
role :app, ec2_server                          # This may be the same as your `Web` server
role :db,  ec2_server, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

namespace :deploy do
  set :app_path, '/app/collectr'
  task :simple, :roles => :app do
    system "git push"
    run_in_app "git checkout ."
    run_in_app "git pull"
    run_in_app "bundle install"
    rake "db:migrate"
    run_in_app "#{try_sudo} touch tmp/restart.txt"
    deploy.post_deploy
  end

  task :post_deploy, :roles => :app do
    rake ENV['POST_DEPLOY'] if ENV['POST_DEPLOY']
  end

  def rake task
    run_in_app "RAILS_ENV=production rake #{task}"
  end

  def run_in_app cmd
    run "cd #{app_path} && #{cmd}"
  end

end