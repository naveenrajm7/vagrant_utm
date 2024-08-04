# frozen_string_literal: true

# Gems
require "rspec"

# Require Vagrant itself so we can reference the proper
# classes to test.
require "vagrant"
require "vagrant/util/platform"

# Load in helpers
require "support/dummy_provider"
require "support/shared/base_context"

require "vagrant_utm"

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
