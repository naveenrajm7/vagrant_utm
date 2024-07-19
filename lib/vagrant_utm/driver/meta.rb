# frozen_string_literal: true

require "forwardable"

require "log4r"

require "vagrant/util/retryable"

require File.expand_path("base", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # This driver uses the AppleScript bridge interface to interact with UTM.
      class Meta < Base
        # This is raised if the VM is not found when initializing a driver
        # with a UUID.
        class VMNotFound < StandardError; end

        # We use forwardable to do all our driver forwarding
        extend Forwardable

        # The UUID of the virtual machine we represent (Name in UTM).
        attr_reader :uuid

        # TODO: get UTM version
        # attr_reader :version

        include Vagrant::Util::Retryable

        # Initializes the driver with the path to the scripts directory.
        def initialize(uuid = nil)
          # Setup the base
          super()

          @uuid = uuid
          # TODO: read UTM version
          # begin
          #   read_version
          # rescue Errors::UtmError
          #   raise
          # end
          @version = "4.5"
          driver_map = {
            "4.5" => Version_4_5
          }

          driver_klass = nil
          driver_map.each do |key, klass|
            if @version.start_with?(key)
              driver_klass = klass
              break
            end
          end

          @driver = driver_klass.new(@uuid)
          # @version = @@version

          return unless @uuid
          # Verify the VM exists, and if it doesn't, then don't worry
          # about it (mark the UUID as nil)
          raise VMNotFound unless @driver.vm_exists?(@uuid)
        end

        def_delegators :@driver,
                       :configure,
                       :import,
                       :list,
                       :read_state,
                       :start,
                       :vm_exists?,
                       :halt,
                       :suspend,
                       :last_uuid
      end
    end
  end
end
