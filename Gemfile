# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in vagrant_utm.gemspec
group :development do
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.0"
  gem "rubocop", "~> 1.21"
  gem "vagrant", git: "https://github.com/hashicorp/vagrant.git", tag: "v2.4.1"
end

group :plugins do
  gem "vagrant_utm", path: "."
end
