# frozen_string_literal: true

require "i18n"
require "vagrant"

module VagrantPlugins
  module Utm
    # This is the configuration class for the UTM provider.
    class Config < Vagrant.plugin("2", :config)
      # The name of the virtual machine.
      #
      # @return [String]
      attr_accessor :name

      # The path to the UTM VM file.
      #
      # @return [String]
      attr_accessor :utm_file

      # Initialize the configuration with unset values.
      def initialize
        super
        @name = UNSET_VALUE
        @utm_file = UNSET_VALUE
      end

      # Make sure the configuration has defined all the necessary values
      def finalize!
        @name = nil if @name == UNSET_VALUE
        @utm_file = nil if @utm_file == UNSET_VALUE
      end
    end
  end
end
