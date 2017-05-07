require 'mina/bundler'  
require 'mina/rails'  
require 'mina/git'  
require 'mina/unicorn'  
require 'mina/rvm'
require 'mina_sidekiq/tasks'

# IP do seu servidor
set :domain, "192.168.1.100"

# Caminho da pasta de deploy
set :deploy_to, "/home/debian/App/Odin"

# Repositorio do seu github/gitlab/bitbucket
set :repository, 'git@github.com:massariolmc/Odin.git'  
# Branch do projeto
set :branch, 'master'  
# Porta do seu servidor ssh
set :port, '22' 

# Permitir por senha o deploy
set :term_mode, nil

# Caminho do RVM instalado. Ele ja assume que estara no caminho padrao. Caso nao, modifique aqui:
# set :rvm_path, '/usr/local/rvm/bin/rvm'

# Arquivos compartilhados
#set :shared_path, ['config/database.yml', 'config/secrets.yml', 'log']  
set :app_path, "#{fetch(:deploy_to)}/#{fetch(:current_path)}"  
set :stage, 'production'  
# Quantidade de releases para manter em producao
set :keep_releases, 2

# Seu usuario de deploy
set :user, 'debian'

# PID do unicorn
set :unicorn_pid, "#{fetch(:deploy_to)}/shared/pids/unicorn.pid"

task :environment do  
  # defina a versao do Ruby que vai usar e a gemset
  invoke :'rvm:use', 'ruby-2.4.0'
end

task :setup => :environment do  
  # Pastas compartilhadas
  # comment  %[mkdir -p "#{fetch(:deploy_to)}/log"]
  # comment %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/log"]

  # comment %[mkdir -p "#{fetch(:deploy_to)}/config"]
  # comment %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/config"]

  # UNICORN
  # /home/deploy/apps/<app>/shared/pids/unicorn.pid
  #
  comment %[mkdir -p "#{fetch(:deploy_to)}/shared/pids"]
  comment %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/pids"]

  # /home/deploy/apps/<app>/shared/sockets/unicorn.sock
  #
  comment %[mkdir -p "#{fetch(:deploy_to)}/shared/sockets"]
  comment %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/sockets"]

  comment %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  comment %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  # YML
  comment %[touch "#{fetch(:deploy_to)}/config/database.yml"]
  comment %[touch "#{fetch(:deploy_to)}/config/secrets.yml"]
  comment  %[echo "-----> EDITE no seu servidor o arquivo #{fetch(:deploy_to)}/config/database.yml."]
  comment  %[echo "-----> EDITE no seu servidor o arquivo #{fetch(:deploy_to)}/config/secrets.yml."]

  comment  %["-----> EDITE no seu servidor o arquivo #{fetch(:deploy_to)}/config/secrets.yml."]
end

desc "Deploys the current version to the server."  
task :deploy => :environment do  
  comment :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    comment :launch do
      invoke :'unicorn:restart'

      comment "mkdir -p #{fetch(:deploy_to)}/tmp/"
      comment "touch #{fetch(:deploy_to)}/tmp/restart.txt"
    end
  end
end 
