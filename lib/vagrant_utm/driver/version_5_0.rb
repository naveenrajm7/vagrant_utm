# frozen_string_literal: true

require "json"

require File.expand_path("version_4_7", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 5.0.x
      class Version_5_0 < Version_4_7 # rubocop:disable Naming/ClassAndModuleCamelCase
        SNAPSHOT_MIN_VERSION = "5.0.6"

        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_5_0")
        end

        def create_snapshot(machine_id, snapshot_name)
          require_snapshot_support!
          execute("snapshot", "create", machine_id, "--name", snapshot_name)
        end

        def delete_snapshot(machine_id, snapshot_name)
          require_snapshot_support!
          execute("snapshot", "delete", machine_id, "--snapshot", snapshot_name)
        end

        def list_snapshots(machine_id)
          require_snapshot_support!
          output = execute("snapshot", "list", machine_id, "--json")
          JSON.parse(output).map { |snapshot| snapshot.fetch("name") }
        end

        def restore_snapshot(machine_id, snapshot_name)
          require_snapshot_support!
          execute("snapshot", "restore", machine_id, "--snapshot", snapshot_name)
        end

        private

        def require_snapshot_support!
          return if Gem::Version.new(read_utm_version) >= Gem::Version.new(SNAPSHOT_MIN_VERSION)

          snapshot_unsupported!
        end

        def read_utm_version
          @read_utm_version ||= execute("version").strip
        end
      end
    end
  end
end
