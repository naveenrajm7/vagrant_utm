# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Default Synced folder implementation for UTM
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      def usable?(machine, _raise_errors = false) # rubocop:disable Style/OptionalBooleanParameter
        # These synced folders only work if the provider is UTM
        if machine.provider_name != :utm
          raise Errors::SyncedFolderNonUtm, provider: machine.provider_name.to_s if raise_errors

          return false
        end

        true
      end

      def prepare(machine, folders, _opts)
        share_folders(machine, folders)
      end

      def enable(machine, folders, _opts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity
        share_folders(machine, folders)

        # short guestpaths first, so we don't step on ourselves
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
            automount: !!data[:automount]
          }
        end

        driver(machine).share_folders(defs)
      end
    end
  end
end
