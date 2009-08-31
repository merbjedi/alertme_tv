namespace :vlad do
  set :domain, "alertme_deploy"
  set :apache_domain, "alertmetv.r09.railsrumble.com"
  set :application, "alertme_tv"
  set :deploy_to, "/var/www/production/#{application}"
  set :repository, "git@github.com:railsrumble/rr09-team-25.git"

  set :user, "deploy"
  set :deploy_folder, "/var/www/production"
  set :apache_site_folder, "/var/www/vhosts"

  set :revision, "master"
  set :merb_env, "production"

  set :keep_releases, 3

  set :linked_files, [
                       "config/database.yml",
                       "config/app_config/production.yml"
                     ]

  # set the list of folders to symlink on deployment
  set :linked_folders, ["public/images/sample", "public/tv_assets"]
  
  # make directories
  set :make_directories, []

  set :web_command, "sudo /etc/init.d/apache2"
  set :rake_cmd, "bin/rake"
  set :git_cmd, "git"
  set :thor_cmd, "thor"
  
  
  desc "Reload the apache configuration (vhost, etc)"
  remote_task :reload_web, :roles => :app do
    run "#{web_command} reload"
  end
  
  desc "Launch a site with sample data"
  task :launch do
    Rake::Task["vlad:setup"].invoke
    Rake::Task["vlad:app:setup_db_config"].invoke
    Rake::Task["vlad:app:setup_vhost"].invoke

    Rake::Task["vlad:update"].invoke
    Rake::Task["vlad:app:gem_redeploy"].invoke
    Rake::Task["vlad:app:slices_install"].invoke

    Rake::Task["vlad:app:symlink_files"].invoke
    Rake::Task["vlad:app:symlink_folders"].invoke
    Rake::Task["vlad:app:bootstrap"].invoke

    Rake::Task["vlad:app:load_sample_data"].invoke rescue nil

    Rake::Task["vlad:app:sass_compile"].invoke

    # complete
    Rake::Task["vlad:start_app"].invoke
    Rake::Task["vlad:cleanup"].invoke

    Rake::Task["vlad:app:enable_site"].invoke

    puts "DONE!"
  end
  
  
  # deploy site (use this for updates)
  desc "Full deployment cycle: Update, migrate, restart, cleanup"
  remote_task :deploy, :roles => :app do
  
    Rake::Task["vlad:update"].invoke
    Rake::Task["vlad:app:gem_redeploy"].invoke
    Rake::Task["vlad:app:slices_install"].invoke

    Rake::Task["vlad:app:symlink_files"].invoke
    Rake::Task["vlad:app:symlink_folders"].invoke
    # Rake::Task["vlad:app:migrate"].invoke
    
    Rake::Task["vlad:app:sass_compile"].invoke
    
    Rake::Task["vlad:app:enable_site"].invoke
    Rake::Task["vlad:start_app"].invoke
    Rake::Task["vlad:cleanup"].invoke

    puts "DONE!"
  end
  
  namespace :app do
    desc "Symlinks the shared configuration files"
    remote_task :symlink_files, :roles => :web do
      
      cmd = Array(linked_files).map do |link|
        [
         "mkdir -p #{File.dirname(shared_path / link)}",
         "mkdir -p #{File.dirname(current_path / link)}",
         "ln -nsf #{shared_path}/#{link} #{current_path}/#{link}"
        ].join(" && ")
      end.join(" && ")

      run cmd unless cmd.blank?
      
    end
    
    desc "Symlinks the shared configuration folders"
    remote_task :symlink_folders, :roles => :web do
      cmd = Array(linked_folders).map do |folder|
        [
          "mkdir -p #{shared_path}/#{folder}",
          "mkdir -p #{current_path}/#{folder}",
          "ln -nsf #{shared_path}/#{folder} #{current_path}/#{folder}"
        ].join(" && ")
      end.join(" && ")
      
      run cmd unless cmd.blank?
    end
    
    desc "Sets up the database YML"
    remote_task :setup_db_config, :roles => :app do
      break unless target_host == Rake::RemoteTask.hosts_for(:app).first
      
      require "highline/import"
      db_name = application # ask("\nEnter a database name:")
      db_server = ask("\nEnter a database server:")
      db_user = ask("\nEnter a database username:")
      db_pass = ask("\nEnter a database password:"){|q| q.echo = "*"}

      database_configuration = %(
        ---
        login: &login
          adapter: mysql
          database: #{db_name}
          host: #{db_server}
          username: #{db_user}
          password: #{db_pass}

        production:
          <<: *login
      )

      local_path = Merb.root / "tmp" / "#{Time.now.to_f}_server.deploy_db.yml"
      Dir.mkdir(File.dirname(local_path)) unless File.exists?(File.dirname(local_path))
      File.open(local_path, 'w') {|f| f.write(database_configuration) }

      run "mkdir -p #{shared_path}/config"
      rsync local_path, "#{shared_path}/config/database.yml"
    end
    
    desc "Sets up the Apache vHost Config"
    remote_task :setup_vhost, :roles => :app do
      vhost_configuration = %(
        <VirtualHost *:80>
          ServerName #{apache_domain}
          DocumentRoot /var/www/production/#{application}/current/public
        </VirtualHost>)

      local_path = Merb.root / "tmp" / "#{Time.now.to_f}_server.apache_site.conf"
      Dir.mkdir(File.dirname(local_path)) unless File.exists?(File.dirname(local_path))
      File.open(local_path, 'w') {|f| f.write(vhost_configuration) }

      run "mkdir -p #{shared_path}/config"
      rsync local_path, "#{shared_path}/config/apache_site.conf"
    end
    
    
    desc "Adds apache symlink and restarts server"
    remote_task :enable_site, :roles => :app do 
      run "ln -nsf #{shared_path}/config/apache_site.conf #{apache_site_folder}/#{application}"
      Rake::Task["vlad:reload_web"].invoke
    end

    desc "Removes apache symlink and restarts server"
    remote_task :disable_site, :roles => :app do 
      run "rm -f #{apache_site_folder}/#{application}"
      Rake::Task["vlad:reload_web"].invoke
    end
    
    desc "Bootstraps the database with some data"
    remote_task :bootstrap, :roles => :app do
      break unless target_host == Rake::RemoteTask.hosts_for(:app).first
      run "cd #{current_path}; #{rake_cmd} MERB_ENV=#{merb_env} db:hack:create"
      run "cd #{current_path}; #{rake_cmd} MERB_ENV=#{merb_env} db:bootstrap"
    end

    desc "Upgrades the DB to the latest schema, migration, and seed"
    remote_task :migrate, :roles => :app do
      break unless target_host == Rake::RemoteTask.hosts_for(:app).first

      directory = case migrate_target.to_sym
                  when :current then current_path
                  when :latest  then current_release
                  else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
                  end
      
      run "cd #{directory}; #{rake_cmd} MERB_ENV=#{merb_env} db:autoupgrade"
      run "cd #{directory}; #{rake_cmd} MERB_ENV=#{merb_env} db:migrate #{migrate_args}"
      run "cd #{directory}; #{rake_cmd} MERB_ENV=#{merb_env} db:seed"
    end
    
    desc 'Redeploy Bundled Merb Gems'
    remote_task :gem_redeploy, :roles => :app do
      run "cd #{current_path}; #{thor_cmd} merb:gem:redeploy"
    end

    desc 'Install Bundled Slices'
    remote_task :slices_install, :roles => :app do
      Merb::Slices.each_slice do |slice|
        puts "INSTALLING SLICE: #{slice.identifier}"
        run "cd #{current_path}; bin/rake slices:#{slice.identifier}:install"
      end
    end

    desc 'Compile SASS'
    remote_task :sass_compile, :roles => :app do
      run "cd #{current_path}; bin/rake sass:compile"
      # TODO: clean out tmp/sass-cache (if exists)
    end
    
  end
  
end