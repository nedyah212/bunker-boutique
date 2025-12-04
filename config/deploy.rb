require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

set :application_name, 'bunker-boutique'
set :domain, 'bunker-boutique'
set :deploy_to, '/home/ec2-user/production/bunker-boutique'
set :current_path, "#{fetch(:deploy_to)}/current"
set :repository, 'git@github.com:nedyah212/bunkerboutique.com.git'
set :branch, 'main'
set :user, 'ec2-user'
set :forward_agent, true
set :rvm_use_path, '/home/ec2-user/.rvm/scripts/rvm'

set :shared_files, fetch(:shared_files, []).push('.env.production', 'config/master.key')

task :remote_environment do
  invoke :'rvm:use', 'ruby-3.4.6'
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'

    invoke :'bundle:install'

    command %{echo "Testing Rails environment:"}
    command %{RAILS_ENV=production bundle exec rails runner "puts 'Rails initialized successfully'"}

    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:release_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        command %{sudo systemctl restart puma}
      end
    end
  end
end