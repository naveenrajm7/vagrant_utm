# frozen_string_literal: true

require "vagrant"

module VagrantPlugins
  module Utm
    # This is the configuration class for the UTM provider.
    class Config < Vagrant.plugin("2", :config)
      # The name of the virtual machine.
      #
      # @return [String]
      attr_accessor :name

      # Initialize the configuration with unset values.
      def initialize
        super
        @name = UNSET_VALUE
      end

      # Make sure the configuration has defined all the necessary values
      def finalize!
        @name = nil if @name == UNSET_VALUE
      end
    end
  end
end
