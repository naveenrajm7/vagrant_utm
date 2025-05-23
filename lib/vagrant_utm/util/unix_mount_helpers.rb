# frozen_string_literal: true

# Copied from vagrant/plugins/synced_folder/unix_mount_helpers.rb
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "shellwords"
require "vagrant/util/retryable"

module VagrantPlugins
  module SyncedFolder
    # Contains helper methods for mounting folders on Unix-based systems.
    module UnixMountHelpers # rubocop:disable Metrics/ModuleLength
      def self.extended(klass)
        unless klass.class_variable_defined?(:@@logger)
          klass.class_variable_set(:@@logger, Log4r::Logger.new(klass.name.downcase)) # rubocop:disable Style/ClassVars
        end
        klass.extend Vagrant::Util::Retryable
      end

      def detect_owner_group_ids(machine, guest_path, mount_options, options) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        mount_uid = find_mount_options_id("uid", mount_options)
        mount_gid = find_mount_options_id("gid", mount_options)

        if mount_uid.nil?
          if options[:owner].to_i.to_s == options[:owner].to_s
            mount_uid = options[:owner]
            class_variable_get(:@@logger).debug("Owner user ID (provided): #{mount_uid}")
          else
            output = { stdout: String.new, stderr: String.new } # Ensure strings are not frozen
            uid_command = "id -u #{options[:owner]}"
            machine.communicate.execute(uid_command,
                                        error_class: Vagrant::Errors::VirtualBoxMountFailed,
                                        error_key: :virtualbox_mount_failed,
                                        command: uid_command,
                                        output: output[:stderr]) { |type, data| output[type] << data if output[type] }
            mount_uid = output[:stdout].chomp
            class_variable_get(:@@logger).debug("Owner user ID (lookup): #{options[:owner]} -> #{mount_uid}")
          end
        else
          machine.ui.warn "Detected mount owner ID within mount options. (uid: #{mount_uid} guestpath: #{guest_path})"
        end

        if mount_gid.nil?
          if options[:group].to_i.to_s == options[:group].to_s
            mount_gid = options[:group]
            class_variable_get(:@@logger).debug("Owner group ID (provided): #{mount_gid}")
          else
            begin
              { stdout: String.new, stderr: String.new } # Ensure strings are not frozen
              gid_command = "getent group #{options[:group]}"
              machine.communicate.execute(gid_command,
                                          error_class: Vagrant::Errors::VirtualBoxMountFailed,
                                          error_key: :virtualbox_mount_failed,
                                          command: gid_command,
                                          output: output[:stderr]) { |type, data| output[type] << data if output[type] }
              mount_gid = output[:stdout].split(":").at(2).to_s.chomp
              class_variable_get(:@@logger).debug("Owner group ID (lookup): #{options[:group]} -> #{mount_gid}")
            rescue Vagrant::Errors::VirtualBoxMountFailed
              if options[:owner] == options[:group] # rubocop:disable Metrics/BlockNesting
                class_variable_get(:@@logger).debug("Failed to locate group `#{options[:group]}`. Group name matches owner. Fetching effective group ID.") # rubocop:disable Layout/LineLength
                output = { stdout: String.new }
                result = machine.communicate.execute("id -g #{options[:owner]}",
                                                     error_check: false) do |type, data|
                  output[type] << data if output[type] # rubocop:disable Metrics/BlockNesting
                end
                mount_gid = output[:stdout].chomp if result.zero? # rubocop:disable Metrics/BlockNesting
                class_variable_get(:@@logger).debug("Owner group ID (effective): #{mount_gid}")
              end
              raise unless mount_gid
            end
          end
        else
          machine.ui.warn "Detected mount group ID within mount options. (gid: #{mount_gid} guestpath: #{guest_path})"
        end
        { gid: mount_gid, uid: mount_uid }
      end

      def find_mount_options_id(id_name, mount_options) # rubocop:disable Metrics/AbcSize
        id_line = mount_options.detect { |line| line.include?("#{id_name}=") }
        if id_line
          match = id_line.match(/,?#{Regexp.escape(id_name)}=(?<option_id>\d+),?/)
          found_id = match["option_id"]
          updated_id_line = [
            match.pre_match,
            match.post_match
          ].find_all { |string| !string.empty? }.join(",")
          if updated_id_line.empty?
            mount_options.delete(id_line)
          else
            idx = mount_options.index(id_line)
            mount_options.delete(idx)
            mount_options.insert(idx, updated_id_line)
          end
        end
        found_id
      end

      def emit_upstart_notification(machine, guest_path)
        # Emit an upstart event if we can
        machine.communicate.sudo <<-NOTIFICATION.gsub(/^ {12}/, "")
            if test -x /sbin/initctl && command -v /sbin/init && /sbin/init 2>/dev/null --version | grep upstart; then
              /sbin/initctl emit --no-wait vagrant-mounted MOUNTPOINT=#{guest_path}
            fi
        NOTIFICATION
      end

      def merge_mount_options(base, overrides) # rubocop:disable Metrics/AbcSize
        base = base.join(",").split(",")
        overrides = overrides.join(",").split(",")
        b_kv = Hash[base.map { |item| item.split("=", 2) }]
        o_kv = Hash[overrides.map { |item| item.split("=", 2) }]
        merged = {}.tap do |opts|
          (b_kv.keys + o_kv.keys).uniq.each do |key|
            opts[key] = o_kv.fetch(key, b_kv[key])
          end
        end
        merged.map do |key, value|
          [key, value].compact.join("=")
        end
      end
    end
  end
end
