source "http://rubygems.org"
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"


gem 'devise', :git => "git://github.com/plataformatec/devise.git"
gem 'activeadmin', :git => "git://github.com/ikusei/active_admin.git", :require => "activeadmin"
gem 'acts-as-taggable-on', :git => 'git://github.com/mbleigh/acts-as-taggable-on.git'
gem 'execjs'
gem 'therubyracer', '~> 0.10.2'
gem "friendly_id"
gem 'omniauth'
gem 'omniauth-openid'
gem 'oa-oauth', :require => 'omniauth/oauth'
gem 'oa-openid', :require => 'omniauth/openid'
gem 'coffee-rails', '~> 3.2.0'
gem 'uglifier', '>= 1.0.3'
gem 'meta-tags', :require => 'meta_tags', :git => "git://github.com/jazzgumpy/meta-tags.git"
gem "paperclip"
gem 'sass-rails'
gem 'compass-rails'
gem 'memcache-client'
gem 'nokogiri', '~> 1.5.3'
gem 'cancan', "1.6.7"

gem "rspec-rails", :group => [:test, :development] # rspec in dev so the rake tasks run properly
gem "faker", :group => [:test, :development] # rspec in dev so the rake tasks run properly
gem "paper_trail"
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'sidekiq'
gem 'sinatra', :require => false
gem 'slim'
gem 'geokit'
gem 'aa_associations'

group :development do
  gem 'thin'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'guard-annotate'
  gem 'pry'
  gem 'pry-nav'
  gem 'brakeman'
  gem 'hirb'
  gem "powder"
end

group :test do
  gem 'mysql2'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'factory_girl'
  gem "factory_girl_rails"
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'guard', '~> 1.1.1'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-livereload'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'growl'
  gem 'launchy'
  gem 'faker'
end
