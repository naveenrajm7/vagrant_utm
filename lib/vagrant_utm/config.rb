# frozen_string_literal: true

require "i18n"
require "vagrant"

module VagrantPlugins
  module Utm
    # This is the configuration class for the UTM provider.
    class Config < Vagrant.plugin("2", :config)
      # If true, will check if guest additions are installed and up to
      # date. By default, this is true.
      #
      # @return [Boolean]
      attr_accessor :check_guest_additions

      # An array of customizations to make on the VM prior to booting it.
      #
      # @return [Array]
      attr_reader :customizations

      # Whether or not this VM has a functional VirtFS 9P filesystem module
      # for VirtFS directory sharing to work.
      # This defaults to true. If you set this to false, then the "utm"
      # synced folder type won't be valid.
      #
      # @return [Boolean]
      attr_accessor :functional_9pfs

      # This should be set to the name of the machine in the UTM GUI.
      #
      # @return [String]
      attr_accessor :name

      # The time to wait for the VM to be 'running' after 'started'.
      #
      # @return [Integer]
      attr_accessor :wait_time

      # Initialize the configuration with unset values.
      def initialize
        super
        @check_guest_additions = UNSET_VALUE
        @customizations = []
        @functional_9pfs = UNSET_VALUE
        @name = UNSET_VALUE
        @wait_time = UNSET_VALUE
      end

      # Customize the VM by calling 'osascript' with the given
      # arguments.
      #
      # When called multiple times, the customizations will be applied
      # in the order given.
      #
      # @param [Array] command An array of arguments to pass to
      # osascript config function.
      def customize(*command)
        # Append the event and command to the customizations array
        event   = command.first.is_a?(String) ? command.shift : "pre-boot"
        command = command[0]
        @customizations << [event, command]
      end

      # Shortcut for setting memory size for the virtual machine.
      # Calls #customize internally.
      #
      # @param size [Integer] the memory size in MB
      def memory=(size)
        customize("pre-boot", ["customize_vm.applescript", :id, "--memory", size.to_s])
      end

      # Shortcut for setting CPU count for the virtual machine.
      # Calls #customize internally.
      #
      # @param count [Integer] the count of CPUs
      def cpus=(count)
        customize("pre-boot", ["customize_vm.applescript", :id, "--cpus", count.to_i])
      end

      # Shortcut for setting the notes of the virtual machine.
      # Calls #customize internally.
      #
      # @param notes [String] the notes for the VM
      def notes=(notes)
        customize("pre-boot", ["customize_vm.applescript", :id, "--notes", notes])
      end

      # Shortcut for setting the directory share mode of the virtual machine.
      # Calls #customize internally.
      #
      # @param mode [String] the directory share mode for the VM
      def directory_share_mode=(mode)
        # The mode can be 'none', 'webDAV', 'virtFS'
        # Convert the mode to the corresponding 4-byte code
        # and pass it to the customize_vm.applescript
        mode_code = case mode.to_s
                    when "none"
                      "SmOf"
                    when "webDAV"
                      "SmWv"
                    when "virtFS"
                      "SmVs"
                    else
                      raise Vagrant::Errors::ConfigInvalid,
                            errors: "Invalid directory share mode, must be 'none', 'webDAV', or 'virtFS'"
                    end
        customize("pre-boot", ["customize_vm.applescript", :id, "--directory-share-mode", mode_code])
      end

      # This is the hook that is called to finalize the object before it
      # is put into use.
      def finalize!
        @check_guest_additions = true if @check_guest_additions == UNSET_VALUE

        @functional_9pfs = true if @functional_9pfs == UNSET_VALUE

        # The default name is just nothing, and we default it
        @name = nil if @name == UNSET_VALUE

        @wait_time = 20 if @wait_time == UNSET_VALUE
      end

      def validate(_machine)
        errors = _detected_errors

        # Add errors if config is invalid Ex: required fields are not set

        valid_events = %w[pre-import pre-boot post-boot post-comm]
        @customizations.each do |event, _| # rubocop:disable Style/HashEachMethods
          next if valid_events.include?(event)

          errors << I18n.t(
            "vagrant.virtualbox.config.invalid_event",
            event: event.to_s,
            valid_events: valid_events.join(", ")
          )
        end

        { "UTM Provider" => errors }
      end

      def to_s
        "UTM"
      end
    end
  end
end
