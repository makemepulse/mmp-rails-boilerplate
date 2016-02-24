# template.rb
def source_paths
  Array(super) + 
    [File.expand_path(File.dirname(__FILE__))]
end


remove_file "README.rdoc"
copy_file "README.md"
gsub_file 'README.md', /__APPNAME__/, app_name.upcase

remove_file ".gitignore"
copy_file ".gitignore"

gdoc_path      = ask("Google spreadsheets CSV url : ")
admin_email    = ask("Admin email : ")
admin_password = ask("Admin password : ")

inside 'config' do
  remove_file 'database.yml'
  create_file 'database.yml' do <<-EOF
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5

development: &development
  <<: *default  
  database: #{app_name}_development
  username: <%= ENV['LOCAL_DB_USERNAME'] %>
  password: <%= ENV['LOCAL_DB_PASSWORD'] %>
  host: <%= ENV['LOCAL_DB_HOSTNAME'] %>

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *development
  database: #{app_name}_test

staging: &staging
  <<: *default
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>

production:
  <<: *staging


EOF
end

  create_file 'translations.yml' do <<-EOF
files:
  global.yml: "#{gdoc_path}"
EOF
  end

  create_file 'env.yml' do <<-EOF
AWS_REGION: "eu-west-1"
AWS_ACCESS_KEY_ID: ""
AWS_SECRET_KEY: ""
EOF
  end

end



remove_file "app/helpers/application_helper.rb"
copy_file "app/helpers/helper.rb", "app/helpers/application_helper.rb"
copy_file "app/models/extensions/uuid_helper.rb"
copy_file "app/views/rails_admin/main/dashboard.html.haml"

remove_file "app/controllers/application_controller.rb"
copy_file "app/controllers/app_controller.rb", "app/controllers/application_controller.rb"
copy_file "app/controllers/api_controller.rb"
empty_directory "app/controllers/api"
run "touch app/controllers/api/.keep"
#empty_directory 'app/models/extensions'

empty_directory 'lib/rails_admin'
inside 'lib/rails_admin' do
    copy_file "dashboard.rb"
    copy_file "publish.rb"
end

inside 'db' do
  remove_file 'seeds.rb'
  copy_file 'seed.rb', 'seeds.rb'

  gsub_file 'seeds.rb', /__ADMIN__/, admin_email.downcase
  gsub_file 'seeds.rb', /__PWD__/, admin_password
end

environment "
  env_file = File.join(Rails.root, 'config', 'env.yml')
  YAML.load(File.open(env_file)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exists?(env_file)", env: 'development'

environment "
  config.action_controller.asset_host    = \"//#{ENV['AWS_ASSET_HOST']}\"
  config.assets.prefix                   = \"/assets\"
  config.action_mailer.asset_host        = ENV['AWS_ASSET_HOST']", env: 'production'

environment "config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.yml').to_s]"
environment "config.cache_store = :memory_store, { size: 16.megabytes, expires_in: 12.hours }"

gem 'uuidtools', '2.1.5'
gem "iso_country_codes", '0.7.4'

gem "fog-aws", '0.8.1'
gem 'asset_sync', '1.1.0'
gem "rails_admin", '0.8.1'
gem "devise", '3.5.5'
gem "cancancan", '1.13.1'

gem 'newrelic_rpm', '3.14.2.312'

gem 'apipie-rails', "0.3.5"
gem 'i18n-docs',"0.0.11", github: "makemepulse/i18n-docs"

gem_group :development, :test do
  
  gem 'quiet_assets'
  gem 'turbo_dev_assets'
end



route '
  apipie
  scope "/:country", constraints: { country: /[A-Z]{2}/ } do

    get "/" => "index#index", :as => "default_no_locale"
    scope "/:locale", constraints: { locale: /[a-z]{2}/ } do
      get "/" => "index#index", :as => "default"

      namespace :api do
        post "user"  => "user#save", :format => [:json]
        get "leaderboard"  => "user#leaderboard", :format => [:json]
      end
    end
  end
  '
#generate(:scaffold, "person name:string")

#route "root to: 'people#index'"
#rake("db:migrate")
 
after_bundle do
  run "spring stop"
  generate "devise:install"
  generate "devise UserAdmin"
  generate "cancan:ability"
  generate "rails_admin:install"  
  generate(:migration, "addParamsToUserAdmin role:integer country_id:integer:index")
  generate(:model, "Country name:string published:boolean:index")
  generate(:model, "Localization name:string code:string published:boolean:index is_default:boolean country_id:integer")
  #run "rails generate model User name:string"


  remove_file "config/initializers/rails_admin.rb"
  remove_file "app/models/ability.rb"
  remove_file "app/models/country.rb"
  remove_file "app/models/localization.rb"
  remove_file "app/models/user_admin.rb"

  copy_file "config/initializers/rails_admin.rb"
  copy_file "app/models/ability.rb"
  copy_file "app/models/country.rb"
  copy_file "app/models/localization.rb"
  copy_file "app/models/user_admin.rb"

  run "newrelic install --license_key='d6ec8c79d2348ac90e1b7f3dcd7c2c93ff804977' '#{app_name}'"



  rake("db:drop")
  rake("db:create")
  rake("db:migrate")
  rake("db:seed")


end