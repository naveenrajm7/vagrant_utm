# frozen_string_literal: true

require "log4r"
require_relative "util/driver"

module VagrantPlugins
  module Utm
    # Provider that is responsible for managing the virtual machine and exposing it to Vagrant.
    class Provider < Vagrant.plugin("2", :provider)
      # The driver for this provider.
      attr_reader :driver

      # Initialize the provider with given machine.
      def initialize(machine)
        super
        @logger = Log4r::Logger.new("vagrant::provider::utm")
        @machine = machine
        @driver = Util::Driver.new
      end

      # Check if the provider is usable.
      # rubocop:disable Style/OptionalBooleanParameter
      def self.usable?(raise_error = false)
        raise Errors::MacOSRequired unless Vagrant::Util::Platform.darwin?

        utm_present = Vagrant::Util::Which.which("utmctl")
        raise Errors::UtmRequired unless utm_present

        true
      rescue Errors::UtmError
        raise if raise_error

        false
      end
      # rubocop:enable Style/OptionalBooleanParameter

      # Execute the action with the given name.
      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)

        nil
      end

      # Return the state of the virtual machine.
      def state
        @logger.info("Getting state of '#{@machine.id}'")

        state_id = nil
        state_id = :not_created unless @machine.id

        unless state_id
          env = @machine.action(:get_state)
          state_id = env[:machine_state_id]
        end

        # Get the short and long description
        short = state_id.to_s
        long  = ""

        # If machine created, then specify the special ID flag
        state_id = Vagrant::MachineState::NOT_CREATED_ID if state_id == :not_created

        Vagrant::MachineState.new(state_id, short, long)
      end
    end
  end
end
