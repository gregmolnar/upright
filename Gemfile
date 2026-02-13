source "https://rubygems.org"

git_source(:github) { |path| "https://github.com/#{path}" }

# Specify your gem's dependencies in upright.gemspec.
gemspec

gem "puma"
gem "sqlite3"
gem "propshaft"
gem "rubocop-rails-omakase", require: false
gem "brakeman", require: false

group :test do
  gem "mocha"
  gem "webmock"
end
