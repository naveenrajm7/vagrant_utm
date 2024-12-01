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
      description <<-DESCRIPTION
      UTM provider allows Vagrant to manage and control
      VMs using UTM through Apple Scripting Bridge.
      DESCRIPTION

      # Register the provider
      provider(:utm, box_optional: true, parallel: false) do
        setup_i18n
        require_relative "provider"
        Provider
      end

      # Register the configuration
      config(:utm, :provider) do
        require_relative "config"
        Config
      end

      # Register capabilities
      provider_capability(:utm, :forwarded_ports) do
        require_relative "cap"
        Cap
      end

      provider_capability(:utm, :snapshot_list) do
        require_relative "cap"
        Cap
      end

      # Register the command
      command "disposable" do
        require_relative "disposable"
        Disposable
      end

      # Load the translation files
      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", Utm.source_root)
        I18n.reload!
      end
    end
  end
end
