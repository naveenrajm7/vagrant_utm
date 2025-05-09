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
      provider(:utm, box_optional: false, parallel: false) do
        setup_i18n
        require_relative "provider"
        Provider
      end

      # Register the configuration
      config(:utm, :provider) do
        require_relative "config"
        Config
      end

      # Register the synced folder implementation
      synced_folder(:utm) do
        require_relative "synced_folder"
        SyncedFolder
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

      synced_folder_capability(:utm, "mount_options") do
        require_relative "cap/mount_options"
        Cap::MountOptions
      end

      synced_folder_capability(:utm, "mount_type") do
        require_relative "cap/mount_options"
        Cap::MountOptions
      end

      synced_folder_capability(:utm, "mount_name") do
        require_relative "cap/mount_options"
        Cap::MountOptions
      end

      # Register the command
      ## Start machine as a snapshot and do not save changes to disk
      command "disposable" do
        require_relative "commands/disposable"
        CommandDisposable
      end

      ## Get the IP address of the machine
      ## Only supported if machine as qemu-guest-additions
      command "ip-address" do
        require_relative "commands/ip_address"
        CommandIpAddress
      end

      # Load the translation files
      def self.setup_i18n
        I18n.load_path << File.expand_path("locales/en.yml", Utm.source_root)
        I18n.reload!
      end
    end
  end
end
