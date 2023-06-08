source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"
gem "bootsnap", require: false
gem "cssbundling-rails"
gem "devise"
gem "devise-i18n"
gem 'rails-i18n'
gem "jbuilder"
gem "jsbundling-rails"

gem "rails", "~> 7.0.5"
gem "puma", "~> 5.0"

gem "stimulus-rails"
gem "sprockets-rails"
gem "font-awesome-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "turbo-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "sqlite3", "~> 1.4"
  gem 'rails-controller-testing'
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
end

group :production do
  gem "pg"
end
