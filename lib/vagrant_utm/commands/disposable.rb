# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Run VM as a snapshot and do not save changes to disk.
    class CommandDisposable < Vagrant.plugin(2, :command)
      def self.synopsis
        "UTM: boots machine in UTM disposable mode"
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant disposable [name|id]"
        end

        # Parse the options
        argv = parse_options(opts)
        return unless argv

        with_target_vms do |machine|
          machine.action(:start_disposable)
        end

        # Success, exit status 0
        0
      end
    end
  end
end
