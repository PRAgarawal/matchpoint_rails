source 'https://rubygems.org'

# Linux
def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end

# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

ruby '2.2.5'

gem 'rails', '5.0.0'
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem 'devise', '~> 4.2.0'
gem 'devise_invitable', '~> 1.6.0'
gem 'pundit', '~> 1.1.0'
gem 'angular-rails-templates'
gem 'sprockets', '3.6.3'
gem 'database_cleaner'
gem 'roo'
gem 'delayed_job_active_record'

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  gem 'rspec', '~> 3.2.0'
  gem 'spring'
  gem 'rspec-rails'
  gem 'childprocess', '>= 0.3.6'
  gem 'jasmine', '~> 2.3.0'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-collection_matchers'
  gem 'bullet'
  gem 'rack-mini-profiler', require: false
  gem 'ruby-prof'
  gem 'listen'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :test do
  gem 'phantomjs'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  # gem 'chromedriver-helper' Chromedriver is known to be broken, only alternative
  # is to download chromdriver from http://chromedriver.storage.googleapis.com/index.html
  gem 'capybara'
  gem 'capybara-angular', '0.1.1'
  gem 'minitest'
  gem 'shoulda-matchers'
  # This is necessary so that the Gemfile.lock file does not change whether you are running
  # in Linux or MacOS
  gem 'growl', '1.0.3', :require => darwin_only('growl')
  gem 'libnotify', '~>0.8.0', :require => linux_only('libnotify')
  gem 'factory_girl_rails', '~>4.4.0'
  gem 'sqlite3'
end

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'rails_12factor', '0.0.3'
  gem 'unicorn', '~>4.8.3'
  gem 'unicorn-worker-killer'
  gem 'heroku-deflater'
  gem 'font_assets'
  gem 'rack-timeout'
end
