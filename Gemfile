source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "bcrypt"
gem "jwt"
gem "devise"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "sidekiq"
gem "redis"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "image_processing"
gem "mini_magick"

gem "bootsnap", require: false

gem "kamal", require: false
gem "kaminari"

gem "thruster", require: false

gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "annotate"
  gem "bullet"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
end
