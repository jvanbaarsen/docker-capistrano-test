namespace :docker do
  desc "See version"
  task :version do
    on roles(:all) do
      execute "docker version"
    end
  end
end
