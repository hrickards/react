set :application, "open_parliament"
set :repository,  "git@github.com:hrickards/open_parliament.git"
set :scm, :git
set :branch, "origin/master"
set :migrate_target, :current
set :ssh_options,     { :forward_agent => true }
set :deploy_to,       "/home/harry/open_parliament"
set :current_path, "/home/harry/open_parliament"
set :normalize_asset_timestamps, false

set :user, "harry"
set :group, "harry"
set :use_sudo, false

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_environment["PATH"]         = "/home/harry/.rvm/gems/ruby-2.0.0-p247/bin:/home/harry/.rvm/gems/ruby-2.0.0-p247@global/bin:/home/harry/.rvm/rubies/ruby-2.0.0-p247/bin:/home/harry/.rvm/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
default_environment["GEM_HOME"]     = "/home/harry/.rvm/gems/ruby-2.0.0-p247"
default_environment["GEM_PATH"]     = "/home/harry/.rvm/gems/ruby-2.0.0-p247:/home/harry/.rvm/gems/ruby-2.0.0-p247@global"
default_environment["RUBY_VERSION"] = "ruby-2.0.0-p247"

default_run_options[:shell] = '/bin/bash -l'

role :web, "151.236.11.195"                          # Your HTTP server, Apache/etc
role :app, "151.236.11.195"                          # This may be the same as your `Web` server

namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
    restart
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git pull"
    finalize_update
  end

  desc "Restart of puma"
  task :restart, :except => { :no_release => true } do
    run "sudo /etc/init.d/puma restart backend"
  end

  desc "Start puma"
  task :start, :except => { :no_release => true } do
    run "sudo /etc/init.d/puma start backend"
  end

  desc "Stop puma"
  task :stop, :except => { :no_release => true } do
    run "sudo/etc/init.d/puma stop backend"
  end
end
