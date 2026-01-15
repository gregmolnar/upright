source "https://rubygems.org"

git_source(:github) { |path| "https://github.com/#{path}" }

# Specify your gem's dependencies in upright.gemspec.
gemspec

gem "puma"
gem "sqlite3"
gem "propshaft"
gem "rubocop-rails-omakase", require: false

# Forked for Ruby 3.4 compatibility (required by engine, git source not supported in gemspec)
gem "geohash_ruby", github: "lewispb/geohash_ruby", branch: "fix-ruby-34-warnings"

group :test do
  gem "mocha"
  gem "webmock"
end
