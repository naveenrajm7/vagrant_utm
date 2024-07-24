# frozen_string_literal: true

require "log4r"

module VagrantPlugins
  module Utm
    # Provider that is responsible for managing the virtual machine and exposing it to Vagrant.
    class Provider < Vagrant.plugin("2", :provider)
      # The driver for this provider.
      attr_reader :driver

      def self.installed?
        Driver::Meta.new
        true
      rescue Errors::UtmError
        raise if raise_error

        false
      end

      # Check if the provider is usable.
      # rubocop:disable Style/OptionalBooleanParameter
      def self.usable?(raise_error = false)
        # Instantiate the driver, which will determine the VirtualBox
        # version and all that, which checks for VirtualBox being present.
        Driver::Meta.new
        true
      rescue Errors::UtmError
        raise if raise_error

        false
      end
      # rubocop:enable Style/OptionalBooleanParameter

      # Initialize the provider with given machine.
      def initialize(machine)
        super
        @logger = Log4r::Logger.new("vagrant::provider::utm")
        @machine = machine

        # This method will load in our driver, so we call it now to
        # initialize it.
        machine_id_changed
      end

      # Execute the action with the given name.
      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)

        nil
      end

      # If the machine ID changed, then we need to rebuild our underlying
      # driver.
      def machine_id_changed
        id = @machine.id

        begin
          @logger.debug("Instantiating the driver for machine ID: #{@machine.id.inspect}")
          @driver = Driver::Meta.new(id)
        rescue Driver::Meta::VMNotFound
          # The virtual machine doesn't exist, so we probably have a stale
          # ID. Just clear the id out of the machine and reload it.
          @logger.debug("VM not found! Clearing saved machine ID and reloading.")
          id = nil
          retry
        end
      end

      # Returns the SSH info for accessing the UTM VM.
      def ssh_info
        # If the VM is not running (utm, started) that we can't possibly SSH into it
        # TODO: We should use the state 'running', rather than 'started'
        # This is a workaround for the UTM provider, which does not expose 'running' state
        return nil if state.id != :started

        # If there is port forwarding, GuestPort 22 to HostPort XXXX,
        # We can use host as "127.0.0.1" and port as XXXX (forwarded ports)
        # But we keep it simple for now, and just use the IP address of the VM
        #
        # Return what we know
        # host = get the IP address of the VM from first IP of utmctl ip-address
        # port = 22, the default SSH port (Since we use IP address of VM, we don't need to forward ports)
        # username = vagrant, the default vagrant user
        # private_key_path = get the private key of the VM (default ~/.vagrant.d/insecure_private_key)

        {
          host: @driver.read_guest_ip,
          port: "22"
        }
      end

      # Return the state of UTM virtual machine by actually
      # querying utmctl.
      #
      # @return [Symbol]
      def state
        @logger.info("Getting state of '#{@machine.id}'")

        # Determine the ID of the state here.
        state_id = nil
        state_id = :not_created unless @driver.uuid
        state_id ||= @driver.read_state
        state_id ||= :unknown

        # Translate into short/long descriptions
        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant_utm.commands.status.#{state_id}")

        # If we're not created, then specify the special ID flag
        state_id = Vagrant::MachineState::NOT_CREATED_ID if state_id == :not_created

        # Return the state
        Vagrant::MachineState.new(state_id, short, long)
      end

      # TODO: Get UUID of the VM from UTM
      # Returns a human-friendly string version of this provider which
      # includes the machine's ID that this provider represents, if it
      # has one.
      #
      # @return [String]
      def to_s
        id = @machine.id || "new VM"
        "UTM (#{id})"
      end
    end
  end
end
