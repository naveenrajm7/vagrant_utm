# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Get All IP Adress of a machine.
    class CommandIpAddress < Vagrant.plugin(2, :command)
      def self.synopsis
        "UTM: outputs ip address of the vagrant machine"
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant ip-address [name|id]"
        end

        # Parse the options
        argv = parse_options(opts)
        return unless argv

        with_target_vms do |machine|
          machine.action(:ip_address)
        end

        0
      end
    end
  end
end
