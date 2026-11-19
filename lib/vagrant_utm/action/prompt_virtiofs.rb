# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Prompts user to manually configure VirtioFS shared folders in UTM GUI
      # for Apple Virtualization VMs. This is required because macOS security-scoped
      # bookmarks cannot be created programmatically.
      class PromptVirtioFS
        include Vagrant::Action::Builtin::MixinSyncedFolders

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]

          # Only prompt for Apple Virtualization VMs with synced folders
          folders = get_synced_folders(machine, env)
          if apple_vm?(machine) && folders.any?
            prompt_for_virtiofs(machine, env, folders)
          end

          @app.call(env)
        end

        private

        def apple_vm?(machine)
          machine.provider_config.skip_directory_share_mode
        end

        def get_synced_folders(machine, env)
          opts = {
            cached: !env[:synced_folders_cached].nil?,
            config: env[:synced_folders_config],
            disable_usable_check: !env[:test].nil?
          }
          all_folders = synced_folders(machine, **opts)

          # Collect non-disabled folder paths
          paths = []
          all_folders.each do |_type, type_folders|
            type_folders.each do |_id, data|
              next if data[:disabled]

              hostpath = File.expand_path(data[:hostpath], machine.env.root_path)
              paths << { hostpath: hostpath, guestpath: data[:guestpath] }
            end
          end
          paths
        rescue StandardError
          []
        end

        def prompt_for_virtiofs(machine, env, folders)
          ui = env[:ui]
          vm_name = machine.provider.driver.read_vm_name rescue nil
          vm_name ||= machine.name.to_s

          ui.warn("")
          ui.warn("=" * 70)
          ui.warn("  MANUAL STEP REQUIRED: VirtioFS Shared Folders")
          ui.warn("=" * 70)
          ui.warn("")
          ui.warn("Apple Virtualization VMs require manual shared folder setup.")
          ui.warn("macOS security restrictions prevent automated configuration.")
          ui.warn("")
          ui.warn("Please complete these steps in UTM:")
          ui.warn("")
          ui.warn("  1. Open UTM application")
          ui.warn("  2. Right-click '#{vm_name}' -> Edit")
          ui.warn("  3. Go to 'Sharing' tab")
          ui.warn("  4. Remove existing entries (if any), then re-add these paths:")
          ui.warn("")
          folders.each do |folder|
            ui.warn("     -> #{folder[:hostpath]}")
            ui.warn("        (mounts at: /Volumes/My Shared Files/#{File.basename(folder[:hostpath])}/)")
          end
          ui.warn("")
          ui.warn("  5. Save the VM settings")
          ui.warn("")
          ui.warn("=" * 70)
          ui.warn("")
          ui.ask("Press ENTER when done to continue booting the VM...")
        end
      end
    end
  end
end
