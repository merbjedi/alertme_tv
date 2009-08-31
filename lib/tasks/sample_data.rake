namespace :db do
  desc "Bootstrap the database with schema and sample data"
  task :bootstrap do
    Rake::Task["db:autoupgrade"].invoke
    Rake::Task["db:seed"].invoke
  end

  task :bootstrap_clean do
    Rake::Task["db:automigrate"].invoke
    Rake::Task["db:seed"].invoke
  end
  
  namespace :hack do  
    desc "Create the database"
    task :create do 
      config = Merb::Orms::DataMapper.config
      puts "Creating database '#{config[:database]}'"
      
      `mysqladmin -h '#{config[:host]}' -u #{config[:username]} #{config[:password] ? "-p'#{config[:password]}'" : ''} create #{config[:database]}`
    end
  end

  desc "Save Databases to schema/backup/\#{repo}.sql"
  task :backup => :merb_env do
    DataMapper::Repository.adapters.each do |adapter|
      adapter_name = adapter.first
      adapter = adapter.last
      db_name = adapter.uri.path.split("/").last
    
      if adapter.is_a? DataMapper::Adapters::MysqlAdapter
        puts "\nBacking up Repository: #{adapter_name}"
        puts "..."
        password_option = "--passsword='#{adapter.uri.password}'" if adapter.uri.password
        cmd = "mysqldump --user='#{adapter.uri.user}' #{password_option} #{db_name} > schema/backup/#{adapter_name}.sql"
      
        # execute it
        `mkdir -p schema/backup/`
        puts `#{cmd}`
        puts "Written to: ./schema/backup/#{adapter_name}.sql\n\n"
      end
    end
  end

  desc "Load Database from schema/db_backup.sql. Set FORCE=true to run without prompting"
  task :restore => :merb_env do    
    DataMapper::Repository.adapters.each do |adapter|
      adapter_name = adapter.first
      adapter = adapter.last
      db_name = adapter.uri.path.split("/").last
      sql_path = "./schema/backup/#{adapter_name}.sql"

      # verify we have an actual file dump
      unless File.exists?(sql_path)
        puts "\nUnable to find DB backup at: #{sql_path}"
        puts "You'll need to place a DB backup file there if you want to restore it.\n\n"
        next
      end
    
      # only support mysql for now
      unless adapter.is_a? DataMapper::Adapters::MysqlAdapter
        next
      end
    
      puts "\nRestoring database (#{db_name}) from ./schema/backup/#{adapter_name}.sql"

      unless ENV["FORCE"]
        puts "This will overwrite your current data. Are you sure you want to continue? [y/N] "
        result = `read INPUT_RESULT;echo $INPUT_RESULT`
        unless result.to_s.downcase[0,1] == "y"
          puts "Canceled"
          next
        end
      end

      # Build Command Line Input to Restore DB
      puts "\nRestoring Repository: #{adapter_name}"
      puts "..."
      password_option = "--passsword='#{adapter.uri.password}'" if adapter.uri.password
      cmd = "mysql --user='#{adapter.uri.user}' #{password_option} --database='#{db_name}' < schema/backup/#{adapter_name}.sql"
      # puts cmd
    
      # execute it
      puts `#{cmd}`
      puts "Loaded DB from: ./schema/backup/#{adapter_name}.sql\n\n"
    end
  end
  
  namespace :sample_data do
    desc "Save Sample Data for a particular model (pass in via model='MyModel')"
    task :save => :merb_env do
      require 'highline/import'
      models = ENV["model"] || ENV["models"] || ask("Which model(s) would you like to save sample data for?")

      # set data path
      dir = Merb.root_path("schema/sample")
      FileUtils.mkdir_p(dir)

      models.strip.split(",").each do |model|
        model_class = Class.const_get(model.strip)
      
        puts "\nSaving sample data for #{model_class.to_s}"
      
        attachment_fields = (model_class.try(:attachment_definitions) || []).map{|k,v| k}

        data = model_class.all.map do |row|
          r = row.attributes
        
          # set timestamps (because yml is a piece of shit)
          date_keys = []
          r.each do |k,v|
            r[k] = "CURRENT_TIMESTAMP" if v.is_a?(Time) or v.is_a?(DateTime)
          end
        
          # save files
          attachment_fields.each do |attachment_field|
            next unless row.send(attachment_field).exists?

            path = row.send(attachment_field).path
            relative_path = path.gsub(Merb.root, "")
          
            FileUtils.mkdir_p(dir / File.dirname(relative_path))
            FileUtils.cp(path, dir / relative_path)
          end
        
          r
        end
      
      
        File.open(dir / "#{model_class.to_s.downcase}.yml", 'w+') { |f| YAML.dump(data, f) }
      end
    end
    
    desc "Loading Sample Data for a particular model (pass in via model='MyModel')"
    task :load => :merb_env do
      require 'highline/import'
      models = ENV["model"] || ENV["models"] || ask("Which model(s) would you like to load sample data for?")

      dir = Merb.root_path("schema/sample")
      FileUtils.mkdir_p(dir)

      models.strip.split(",").each do |model|
        model_class = Class.const_get(model.strip)
      
        puts "\nLoading sample data for #{model_class.to_s}"

        adapter = DataMapper.repository(:default).adapter
        model_class.all.destroy!
        model_class.transaction do |txn|
          puts "Loading #{model_class} data..."
        
          file_loader = []
          YAML.load_file(dir / "#{model_class.to_s.downcase}.yml").each do |fixture|
            values = fixture.values.map do |v|
              if v == "CURRENT_TIMESTAMP"
                Time.now
              else
                v
              end
            end
            adapter.execute("INSERT INTO #{model_class.name.pluralize.snake_case} (#{fixture.keys.join(",")}) VALUES (#{values.collect {|value| adapter.send(:quote_column_value, value)}.join(",")})")
          end
        end
      end
      
      # move public data
      Dir[dir / "public" / "*"].each do |d|
        next unless File.directory?(d)
      
        root = Merb.root_path("public") / File.basename(d)
        FileUtils.mkdir_p(root)
        Dir[d / "*"].each do |inner|
          FileUtils.cp_r(inner, root)
        end
      end
    end
  end
end