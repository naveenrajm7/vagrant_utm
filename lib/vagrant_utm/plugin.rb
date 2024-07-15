# frozen_string_literal: true

# check if the Vagrant gem is available
begin
  require "vagrant"
rescue LoadError
  raise "The 'vagrant' gem could not be found. Please make sure it is installed."
end

# check if the Vagrant version is sufficient
raise "The Vagrant UTM plugin is only compatible with Vagrant 2.3 or later" if Vagrant::VERSION < "2.3.0"

module VagrantPlugins
  module Utm
    # This is the main entry point for the UTM provider plugin.
    class Plugin < Vagrant.plugin("2")
      name "utm"
      description "UTM provider for Vagrant"

      #   # Register the configuration
      #   config(:utm, :provider) do
      #     require_relative "config"
      #     Config
      #   end

      # Register the provider
      provider(:utm) do
        require_relative "provider"
        Provider
      end
    end
  end
end
