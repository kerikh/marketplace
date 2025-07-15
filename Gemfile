# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

gem "rails", "~> 7.1.0"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"

gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "webpacker", "~> 4.1", ">= 4.1.0"
gem "haml-rails", ">= 2.0.1"
gem "turbolinks", "~> 5", require: false

gem "bootsnap", ">= 1.1.0", require: false
gem "colorize", ">= 0.8.1", require: false

gem "ancestry", ">= 3.0.6"
gem "gretel"
gem "will_paginate", "~> 3.1.0"
gem "will_paginate-bootstrap4"
gem "simple_form", ">= 5.0.0"
gem "friendly_id", "~> 5.3.0"
gem "acts-as-taggable-on", "~> 6.0"
gem "countries"

gem "activestorage-validator", ">= 0.1.3"
gem "image_processing", "~> 1.9.2"

# turbo-charged counter caches
gem "counter_culture", "~> 2.2", ">= 2.2.0"

# validation
gem "valid_email2", ">= 3.0.2"
gem "json-schema"
gem "validate_url", github: "perfectline/validates_url"

gem "searchkick"
gem "devise", ">= 4.7.0"
gem "omniauth", ">= 2.1.0"
gem "omniauth_openid_connect", ">= 0.4.0"
gem "pundit", "~> 2.1", ">= 2.1.0"
gem "role_model"
gem "recaptcha", require: "recaptcha/rails"

# Markdown
gem "github-markup"
gem "redcarpet"

# jira
gem "jira-ruby", ">= 1.6.0"

gem "redis-rails"
gem "sidekiq", ">= 5.2.6"

gem "custom_error_message", git: "https://github.com/thethanghn/custom-err-msg.git"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]

  gem "rspec-rails", "~> 3.8.3"

  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "pry-doc", ">= 0.13.0"
  gem "pry-nav"

  gem "dotenv-rails", ">= 2.7.6"

  gem "selenium-webdriver", ">= 3.141.592"
  gem "webdrivers", "~> 3.8", ">= 3.8.0"
end

group :development do
  gem "web-console", ">= 4.0.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rubocop-rails_config"
  gem "overcommit", require: false
  gem "haml_lint", require: false
  gem "scss_lint", require: false
end

group :test do
  gem "factory_bot_rails", ">= 5.0.2"
  gem "shoulda-matchers", ">= 4.1.0"
  gem "capybara", ">= 3.16.2"
  gem "database_cleaner"
  gem "rack_session_access"
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :production do
  gem "sentry-raven"
  gem "faker", require: false
  gem "newrelic_rpm"
end

gem "unirest"
gem "reverse_markdown", ">= 1.2.0"
