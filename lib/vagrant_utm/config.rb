# frozen_string_literal: true

require "i18n"
require "vagrant"

module VagrantPlugins
  module Utm
    # This is the configuration class for the UTM provider.
    class Config < Vagrant.plugin("2", :config)
      # This should be set to the name of the machine in the UTM GUI.
      #
      # @return [String]
      attr_accessor :name

      # The path to the UTM VM file.
      #
      # @return [String]
      attr_accessor :utm_file_url

      # If true, will check if guest additions are installed and up to
      # date. By default, this is true.
      #
      # @return [Boolean]
      attr_accessor :check_guest_additions

      # An array of customizations to make on the VM prior to booting it.
      #
      # @return [Array]
      attr_reader :customizations

      # The time to wait for the VM to be 'running' after 'started'.
      #
      # @return [Integer]
      attr_accessor :wait_time

      # Initialize the configuration with unset values.
      def initialize
        super
        @check_guest_additions = UNSET_VALUE
        @customizations = []
        @name = UNSET_VALUE
        @utm_file_url = UNSET_VALUE
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
      # @param size [Integer, String] the memory size in MB
      def memory=(size)
        customize("pre-boot", ["customize_vm.applescript", :id, "--memory", size.to_s])
      end

      # Shortcut for setting CPU count for the virtual machine.
      # Calls #customize internally.
      #
      # @param count [Integer, String] the count of CPUs
      def cpus=(count)
        customize("pre-boot", ["customize_vm.applescript", :id, "--cpus", count.to_i])
      end

      # This is the hook that is called to finalize the object before it
      # is put into use.
      def finalize!
        @check_guest_additions = true if @check_guest_additions == UNSET_VALUE
        # The default name is just nothing, and we default it
        @name = nil if @name == UNSET_VALUE
        @utm_file_url = nil if @utm_file_url == UNSET_VALUE
        @wait_time = 10 if @wait_time == UNSET_VALUE
      end
    end
  end
end
