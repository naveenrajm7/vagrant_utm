# frozen_string_literal: true

require "log4r"
# require_relative "util/driver"

module VagrantPlugins
  module Utm
    # This is the provider for UTM.
    class Provider < Vagrant.plugin("2", :provider)

      # Initialize the provider with given machine.
      def initialize(machine)
        super
        @logger = Log4r::Logger.new("vagrant::provider::utm")
        @machine = machine
        @driver = nil
      end

      # Check if the provider is usable.
      def self.usable?(raise_error = false)
        raise Errors::MacOSRequired unless Vagrant::Util::Platform.darwin?

        utm_present = Vagrant::Util::Which.which("utmctl")
        raise Errors::UtmRequired unless utm_present

        true
      rescue Errors::UtmError
        raise if raise_error
        false
      end
    end
  end
end
