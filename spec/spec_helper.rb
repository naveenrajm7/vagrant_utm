# frozen_string_literal: true

require "rspec"

require "vagrant_utm"
require "vagrant_utm/config"
require "vagrant_utm/provider"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Load the translations
  VagrantPlugins::Utm::Plugin.setup_i18n
end
