# frozen_string_literal: true

begin
  require "bundler/gem_tasks"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)

  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  task default: %i[spec rubocop]
rescue LoadError
  # Allow rake to work without full dev dependencies
end

namespace :test do
  desc "Run unit tests"
  task :unit do
    sh "bundle exec rspec spec/"
  end

  desc "Run acceptance tests (requires macOS + UTM + macOS box)"
  task :acceptance do
    sh "bundle exec rspec test/acceptance/"
  end

  desc "Run macOS acceptance tests (shell script)"
  task :macos do
    sh "test/acceptance/macos/run.sh"
  end
end
