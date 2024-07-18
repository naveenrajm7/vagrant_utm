# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Model
      # Represents the result of a 'utmctl list' operation.
      class ListResult
        # @return [Array<ListResultItem>] The list of machines.
        attr_accessor :names

        # Initialize the result from raw data.
        # @param [Array<Hash>] data The raw data.
        def initialize(data)
          @machines = []
          data.each do |machine|
            item = ListResultItem.new(machine)
            @machines << item
          end
        end

        # Checks if a machine with the given name exists.
        # @param [String] name The name of the machine.
        # @return [Boolean]
        def any?(name)
          @machines.any? { |i| i.name == name }
        end

        # Finds a machine with the given name.
        # @param [String] name The name of the machine.
        # @return [ListResultItem]
        def find(name)
          @machines.find { |i| i.name == name }
        end

        # Return the last machine in the list.
        # @return [ListResultItem]
        def last
          @machines.last
        end

        # Represents an item in the list result.
        class ListResultItem
          # @return [String] The UUID of the machine.
          attr_accessor :uuid
          # @return [String] The name of the machine.
          attr_accessor :name
          # @return [String] The state of the machine.
          attr_accessor :state

          # Initialize the result from raw data.
          # @param [Hash] data The raw data.
          def initialize(data)
            @uuid = data["UUID"]
            @name = data["Name"]
            @state = data["Status"]
          end

          # Returns the state of the machine using Vagrant symbols.
          def vagrant_state
            case @state
            when "running"
              :running
            when "stopped", "suspended"
              :stopped
            else
              :host_state_unknown
            end
          end
        end
      end
    end
  end
end
