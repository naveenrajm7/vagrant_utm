# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Contains all the supported capabilities of the UTM provider.
    module Cap
      # Reads the forwarded ports that currently exist on the machine
      # itself. This raises an exception if the machine isn't running (UTM 'started').
      #
      # TODO: This also may not match up with configured forwarded ports, because
      # Vagrant auto port collision fixing may have taken place.
      #
      # @return [Hash<Integer, Integer>] Host => Guest port mappings.
      def self.forwarded_ports(machine)
        return nil if machine.state.id != :started

        {}.tap do |result|
          machine.provider.driver.read_forwarded_ports.each do |_, _, h, g|
            result[h] = g
          end
        end
      end

      # Returns a list of the snapshots that are taken on this machine.
      #
      # @return [Array<String>] Snapshot Name
      def self.snapshot_list(machine)
        return [] if machine.id.nil?

        begin
          machine.provider.driver.list_snapshots(machine.id)
        rescue VagrantPlugins::Utm::Errors::CommandError => e
          raise Errors::SnapShotCommandFailed, {
            stderr: e.inspect
          }
        end
      end
    end
  end
end
