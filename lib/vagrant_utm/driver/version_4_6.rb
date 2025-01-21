# frozen_string_literal: true

require File.expand_path("version_4_5", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 4.6.x
      class Version_4_6 < Version_4_5 # rubocop:disable Naming/ClassAndModuleCamelCase
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_4_6")
        end

        # Implement clear_shared_folders
        def clear_shared_folders
          # Get the list of shared folders
          shared_folders = read_shared_folders
          # Get the args to remove the shared folders
          script_path = @script_path.join("read_shared_folders_args.js")
          cmd = ["osascript", script_path.to_s, @uuid, "--ids", shared_folders.join(",")]
          output = execute_shell(*cmd)
          result = JSON.parse(output)
          return unless result["status"]

          # Flatten the list of args and build the command
          sf_args = result["result"].flatten
          return unless sf_args.any?

          command = ["remove_qemu_additional_args.applescript", @uuid, "--args", *sf_args]
          execute_osa_script(command)
        end

        def import(utm)
          utm = Vagrant::Util::Platform.windows_path(utm)

          vm_id = nil

          command = ["import_vm.applescript", utm]
          output = execute_osa_script(command)

          @logger.debug("Import output: #{output}")

          # Check if we got the VM ID
          if output =~ /virtual machine id ([A-F0-9-]+)/
            vm_id = ::Regexp.last_match(1) # Capture the VM ID
          end

          vm_id
        end

        def export(path)
          @logger.debug("Exporting UTM file to: #{path}")
          command = ["export_vm.applescript", @uuid, path]
          execute_osa_script(command)
        end

        def read_shared_folders
          @logger.debug("Reading shared folders")
          script_path = @script_path.join("read_shared_folders.js")
          cmd = ["osascript", script_path.to_s, @uuid]
          output = execute_shell(*cmd)
          result = JSON.parse(output)
          return unless result["status"]

          # Return the lits of shared folders names(id)
          result["result"]
        end

        def share_folders(folders)
          # sync folder cleanup will call clear_shared_folders
          # This is just a precaution, to make sure we don't
          # have duplicate shared folders
          shared_folders = read_shared_folders
          @logger.debug("Shared folders: #{shared_folders}")
          @logger.debug("Sharing folders: #{folders}")

          folders.each do |folder|
            # Skip if the folder is already shared
            next if shared_folders.include?(folder[:name])

            args = ["--id", folder[:name],
                    "--dir", folder[:hostpath]]
            command = ["add_folder_share.applescript", @uuid, *args]
            execute_osa_script(command)
          end
        end

        # TODO: Implement unshare_folders
        def unshare_folders(folders)
          folders.each do |folder|
            @logger.debug("NOT IMPLEMENTED: unshare_folders(#{folder})")
          end
        end
      end
    end
  end
end
