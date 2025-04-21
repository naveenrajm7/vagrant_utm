# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require_relative "../util/unix_mount_helpers"

module VagrantPlugins
  module Utm
    module Cap
      # Capability for mount options
      module MountOptions
        extend VagrantPlugins::SyncedFolder::UnixMountHelpers

        # Mount type for VirtFS
        UTM_MOUNT_TYPE = "9p"

        # Returns mount options for a utm synced folder
        #
        # @param [Machine] machine
        # @param [String] name of mount
        # @param [String] path of mount on guest
        # @param [Hash] hash of mount options
        def self.mount_options(machine, _name, guest_path, options)
          mount_options = options.fetch(:mount_options, [])
          detected_ids = detect_owner_group_ids(machine, guest_path, mount_options, options)
          mount_uid = detected_ids[:uid]
          mount_gid = detected_ids[:gid]

          # VirtFS mount options
          mount_options << "trans=virtio"
          mount_options << "version=9p2000.L"
          mount_options << if mount_options.include?("ro")
                             "ro"
                           else
                             "rw"
                           end
          mount_options << "_netdev"
          mount_options << "nofail"

          mount_options = mount_options.join(",")
          [mount_options, mount_uid, mount_gid]
        end

        def self.mount_type(_machine)
          UTM_MOUNT_TYPE
        end

        def self.mount_name(_machine, name, _data)
          name.gsub(%r{[\s/\\]}, "_").sub(/^_/, "")
        end
      end
    end
  end
end
