namespace :docker do
  set :docker_app_root, "/apps/docker_test"
  desc "See version"
  task :version do
    on roles(:all) do
      execute "docker version"
    end
  end

  task :prepare_server do
    on roles(:all) do
      execute "mkdir -p #{deploy_to}"
      invoke "git:create_release"
    end
  end

  task :create_container do
    on roles(:all) do
      invoke "docker:prepare_server"
      within release_path do
        execute "cd #{release_path} && docker build -t #{fetch(:application)} ."
      end
    end
  end
end
