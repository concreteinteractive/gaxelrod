source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem "factory_girl_rails"

gem 'gga4r'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  #https://github.com/bkeepers/dotenv
  #Reads environment variables from a .env file in the project root (.gitignored so secret variables aren't in github)
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'rack-test'
  gem 'spork'

  #Setup Jasmine with Guard
  #https://gist.github.com/956438
  gem 'guard'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  gem 'jasmine'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
