# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Default Synced folder implementation for UTM
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      def usable?(machine, _raise_errors = false) # rubocop:disable Style/OptionalBooleanParameter
        # These synced folders only work if the provider is UTM
        return false if machine.provider_name != :utm

        # This only happens with `vagrant package --base`. Sigh.
        return true unless machine.provider_config

        machine.provider_config.functional_9pfs
      end

      # This is called before VM Boot to prepare the synced folders.
      # Add required configs to the VM.
      def prepare(machine, folders, _opts)
        # Skip if no folders to share
        return if folders.empty?

        # For Apple Virtualization VMs, skip automated setup - it doesn't work
        # because macOS security-scoped bookmarks cannot be created programmatically.
        # The PromptVirtioFS action will prompt user to add folders via UTM GUI.
        return if apple_vm?(machine)

        # For QEMU VMs, configure 9pfs sharing
        begin
          share_folders(machine, folders)
        rescue StandardError => e
          machine.ui.warn("Could not configure shared folders: #{e.message}")
        end
      end

      # This is called after VM Boot to mount the synced folders.
      # Mount the shared folders inside the VM.
      def enable(machine, folders, _opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
        # For Apple Virtualization, VirtioFS auto-mounts at /Volumes/My Shared Files/
        # User configures shared folders manually via UTM GUI (prompted before boot)
        if apple_vm?(machine)
          machine.ui.info("VirtioFS shared folders auto-mount at /Volumes/My Shared Files/")
          return
        end

        # For QEMU VMs, configure and mount via 9pfs
        share_folders(machine, folders)

        # Check if guest supports mounting
        unless machine.guest.capability?(:mount_virtualbox_shared_folder)
          return
        end

        # sort guestpaths first, so we don't step on ourselves
        folders = folders.sort_by do |_id, data|
          if data[:guestpath]
            data[:guestpath].length
          else
            # A long enough path to just do this at the end.
            10_000
          end
        end

        # Go through each folder and mount
        machine.ui.output(I18n.t("vagrant.actions.vm.share_folders.mounting"))
        # refresh fstab
        fstab_folders = [] # rubocop:disable Lint/UselessAssignment
        folders.each do |id, data|
          if data[:guestpath]
            # Guest path specified, so mount the folder to specified point
            machine.ui.detail(I18n.t("vagrant.actions.vm.share_folders.mounting_entry",
                                     guestpath: data[:guestpath],
                                     hostpath: data[:hostpath]))

            # Dup the data so we can pass it to the guest API
            data = data.dup

            # Calculate the owner and group
            ssh_info = machine.ssh_info
            data[:owner] ||= ssh_info[:username]
            data[:group] ||= ssh_info[:username]

            # Unmount the folder before we mount it
            machine.guest.capability(
              :unmount_virtualbox_shared_folder,
              data[:guestpath], data
            )

            # Mount the actual folder
            machine.guest.capability(
              :mount_virtualbox_shared_folder,
              os_friendly_id(id), data[:guestpath], data
            )
          else
            # If no guest path is specified, then automounting is disabled
            machine.ui.detail(I18n.t("vagrant.actions.vm.share_folders.nomount_entry",
                                     hostpath: data[:hostpath]))
          end
        end
      end

      def disable(machine, folders, _opts)
        if machine.guest.capability?(:unmount_virtualbox_shared_folder)
          folders.each_value do |data|
            machine.guest.capability(
              :unmount_virtualbox_shared_folder,
              data[:guestpath], data
            )
          end
        end

        # Remove the shared folders from the VM metadata
        names = folders.map { |id, _data| os_friendly_id(id) }
        driver(machine).unshare_folders(names)
      end

      def cleanup(machine, _opts)
        driver(machine).clear_shared_folders if machine.id && machine.id != ""
      end

      protected

      # This is here so that we can stub it for tests
      def driver(machine)
        machine.provider.driver
      end

      def os_friendly_id(id)
        id.gsub(%r{[\s/\\]}, "_").sub(/^_/, "")
      end

      # Check if this is an Apple Virtualization VM (opt-in via config)
      def apple_vm?(machine)
        machine.provider_config.skip_directory_share_mode
      end

      # share_folders sets up the shared folder definitions on the
      # UTM VM.
      #
      def share_folders(machine, folders)
        defs = []

        folders.each do |id, data|
          hostpath = data[:hostpath]
          hostpath = Vagrant::Util::Platform.cygwin_windows_path(hostpath) unless data[:hostpath_exact]

          defs << {
            name: os_friendly_id(id),
            hostpath: hostpath.to_s,
            automount: !data[:automount].nil?
          }
        end

        driver(machine).share_folders(defs)
      end
    end
  end
end
