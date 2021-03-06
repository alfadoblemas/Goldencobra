# encoding: utf-8

require "friendly_id"
require 'ancestry'
require 'devise'
require 'cancan'
require 'meta_tags'
require 'sass'
require 'sprockets'
require 'sprockets/railtie'
require 'sass-rails'
require 'acts-as-taggable-on'
require 'paperclip'
require 'liquid'
require 'geocoder'
require "paper_trail"
require 'sunspot_rails'
require 'sunspot_solr'
# require "pdfkit"
# require 'wkhtmltopdf-binary'
# require "wicked_pdf"
require 'sidekiq'
require 'sinatra'
require 'slim'
require 'geokit'
require "rack/utf8_sanitizer"
require 'simple_enum'
require 'active_model_serializers'

module Goldencobra
  class Engine < ::Rails::Engine

    isolate_namespace Goldencobra
    initializer "goldencobra.load_app_instance_data" do |app|
      #app.class.configure do
        #call some action
      #end
    end

    initializer("goldencobra.locales") do |app|
      Goldencobra::Engine.config.i18n.load_path += Dir[root.join('config', 'locales', '*.{rb,yml}').to_s]
    end

    initializer "goldencobra.assets.precompile" do |app|
      app.config.assets.precompile += %w(goldencobra/react_0.13.1.min.js)
    end

    config.to_prepare do
      #ActionController::Base.send :include, Goldencobra::ArticlesController
      ApplicationController.helper(Goldencobra::ApplicationHelper)
      ActionController::Base.helper(Goldencobra::ApplicationHelper)
      DeviseController.helper(Goldencobra::ApplicationHelper)
      Devise::SessionsController.helper(Goldencobra::ApplicationHelper)
      Devise::PasswordsController.helper(Goldencobra::ApplicationHelper)

      ApplicationController.helper(Goldencobra::ArticlesHelper)
      ActionController::Base.helper(Goldencobra::ArticlesHelper)
      DeviseController.helper(Goldencobra::ArticlesHelper)
      Devise::SessionsController.helper(Goldencobra::ArticlesHelper)
      Devise::PasswordsController.helper(Goldencobra::ArticlesHelper)


    end

    require "#{Goldencobra::Engine.root}/app/middleware/goldencobra/handle_invalid_percent_encoding.rb"
    # NOTE: These must be in this order relative to each other.
    # HandleInvalidPercentEncoding just raises for encoding errors it doesn't cover,
    # so it must run after (= be inserted before) Rack::UTF8Sanitizer.
    config.middleware.insert 0, Goldencobra::HandleInvalidPercentEncoding
    config.middleware.insert 0, Rack::UTF8Sanitizer  # from a gem
  end
end
