# Rakefile
require "./models"

db_conf = YAML.load_file(File.expand_path("../config/database.yml", __FILE__))
ActiveRecord::Tasks::DatabaseTasks.database_configuration = db_conf

require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app"
  end
end