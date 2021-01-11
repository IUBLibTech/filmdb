source 'https://rubygems.org'

# need to add the passenger gem for Sycamore because of upgrading ruby/rails/bundler
gem 'passenger'

gem 'rails', '~> 4.2'

# Use mysql as the database for Active Record
# hold back mysql2 gem as newer ones are actually broken with newer activerecord
gem 'mysql2', '0.4.10'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'nested_form'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# User jquery-ui
gem 'jquery-ui-rails'

# rails polymorphism for multiple format support
gem 'active_record-acts_as'

# replaces the rails default javascript alert with a jquery version: https://github.com/mois3x/sweet-alert-rails-confirm - this is BUGGY!!!
# replacing default railds data-confirm with sweet alerts manually. See: http://thelazylog.com/custom-dialog-for-data-confirm-in-rails/
# gem 'rails-assets-sweetalert2', source: 'https://rails-assets.org'
# gem 'sweet-alert-confirm'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# HairTrigger lets you create and manage database triggers in a concise, db-agnostic, Rails-y way.
gem 'hairtrigger'

# pundit adds authorization support
gem 'pundit'

# roo adds XLSX read-only support
gem 'roo'

# handle email notifications
gem 'mail'

# railsconfig/config - used to get yaml configuration in config/settings/[ENV].yaml files
gem 'config'

gem 'net-scp'

# gem 'will_paginate', '~> 3.1.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'web-console', '~> 2.0', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rspec-rails'
  gem 'simplecov'
end

group :test do
  gem 'factory_girl_rails'
end