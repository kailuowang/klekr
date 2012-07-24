default_run_options[:pty] = true

require 'bundler/capistrano'
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :application, "collectr"
set :repository, "git@github.com:kailuowang/klekr.git"
set :user, "ec2-user"
set :scm, :git
set :deploy_to, '/apps/'
set :ec2_server, 'klekr.com'

set :environment, 'production'
set :branch, 'master'
set :rails_env, "RAILS_ENV=#{environment}"

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
  set :current_path, app_path
  set :release_path, app_path


  task :simple, :roles => :app do

    #_, bkp_path, _ = db_backup_dir_and_path()
    #deploy.db_backup unless File.exist?(bkp_path)
    deploy.bring_site_down

    deploy.checkout_code
    deploy.bundle

    #deploy.clear_cron
    #depploy.stop_delayed_job
    deploy.migrate
    deploy.prepare_assets
    #deploy.update_cron
    deploy.restart_passenger
    deploy.bring_site_up
    #deploy.start_delayed_job
    deploy.post_deploy
    deploy.warm_server
  end

  task :stop_delayed_job, :roles => :app do
    run_in_app "#{rails_env} script/delayed_job stop"
  end

  task :migrate, :roles => :app do
    rake "db:migrate"
  end

  task :update_cron, :roles => :app do
    run_in_app "bundle exec whenever --update-crontab collectr"
  end

  task :clear_cron, :roles => :app do
    run_in_app "bundle exec whenever --clear-crontab collectr"
  end

  task :bundle, :roles => :app do
    run_in_app "bundle install --without test development"
  end

  task :bundle_update, :roles => :app do
    run_in_app "bundle update"
  end

  task :get_logs, :roles => :app do
    download "#{app_path}/log/cron.log", "log/cron.log"
    download "#{app_path}/log/production.log", "log/production.log"
  end

  task :tail_log, :roles => :app do
    run_in_app "tail -f log/production.log"
  end

  task :tail_cron_log, :roles => :app do
    run_in_app "tail -n 2000 log/cron.log"
  end

  task :patch, :roles => :app do
    deploy.bring_site_down
    deploy.checkout_code
    deploy.restart_passenger
    deploy.bring_site_up
    deploy.prepare_assets
    deploy.warm_server
  end

  task :upgrade_gems, :roles => :app do
    deploy.bring_site_down
    deploy.checkout_code
    deploy.bundle_update
    deploy.bundle
    deploy.restart_passenger
    deploy.bring_site_up
    deploy.warm_server
  end

  task :minor_patch, :roles => :app do
    deploy.checkout_code
    deploy.restart_passenger
    deploy.warm_server
  end

  task :prepare_assets do
    run_in_app 'cp -r app/assets/images/* public/assets/'
    rake "assets:precompile"
  end

  task :bring_site_down do
    run_in_app 'cp public/system/maintenance.html.bkp public/system/maintenance.html'
  end

  task :bring_site_up do
    run_in_app 'rm public/system/maintenance.html'
  end

  task :warm_server do
    system "curl #{ec2_server}"
  end

  task :start_delayed_job, :roles => :app do
    run_in_app "#{rails_env} script/delayed_job start"
  end

  task :restart_apache, :roles => :app do
    run_in_app "#{try_sudo} apachectl -k graceful"
  end

  task :post_deploy, :roles => :app do
    rake ENV['POST_DEPLOY'] if ENV['POST_DEPLOY'] && !ENV['POST_DEPLOY'].empty?
  end

  task :db_backup, :roles => :app do
    bkp_dir, bkp_path, bkp_zip_path = db_backup_dir_and_path
    run_in_app "mkdir -p #{bkp_dir}"
    run_in_app "mysqldump collectr -u root > #{bkp_path}"
    run_in_app "zip #{bkp_zip_path} #{bkp_path}"
    system "mkdir -p #{bkp_dir}"
    download "#{app_path}/#{bkp_zip_path}", bkp_zip_path, via: :scp
  end

  task :report, :roles => :app do
    rake 'admin:report:statistics'
  end

  task :restart_passenger, :role => :app do
    run_in_app "#{try_sudo} touch tmp/restart.txt"
  end

  task :one_time_sync, :roles => :app do
    run_in_app "nohup bundle exec rake --trace sync:all_streams RAILS_ENV=production > log/onetime_sync.out 2> ontime_sync.err < /dev/null  &"
  end

  task :checkout_code, :roles => :app do
    run_in_app "git checkout ."
    run_in_app "git fetch"
    run_in_app "git checkout #{branch}"
    run_in_app "git pull"
  end

  def db_backup_dir_and_path
    file_name = "collectr-db-backup-#{Date.today.to_s}"
    bkp_dir = "db/bkp"
    bkp_path = "#{bkp_dir}/#{file_name}.sql"
    bkp_zip_path = "#{bkp_dir}/#{file_name}.zip"
    return bkp_dir, bkp_path, bkp_zip_path
  end

  def rake task
    run_in_app "#{rails_env} bundle exec rake #{task} --trace"
  end

  def run_in_app cmd
    run "cd #{app_path} && #{cmd}"
  end

end
