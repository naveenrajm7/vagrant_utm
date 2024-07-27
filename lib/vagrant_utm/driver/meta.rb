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

        # We cache the read UTM version here once we have one,
        # since during the execution of Vagrant, it likely doesn't change.
        @version = nil
        @@version_lock = Mutex.new # rubocop:disable Style/ClassVars

        # The UUID of the virtual machine we represent (Name in UTM).
        attr_reader :uuid

        # The version of UTM that is running.
        attr_reader :version

        include Vagrant::Util::Retryable

        def initialize(uuid = nil) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
          # Setup the base
          super()

          @logger = Log4r::Logger.new("vagrant::provider::utm::meta")
          @uuid = uuid

          @@version_lock.synchronize do
            unless @version
              begin
                @version = read_version
              rescue Errors::CommandError
                # This means that UTM was not found, so we raise this
                # error here.
                raise Errors::UtmNotDetected
              end
            end
          end

          # Instantiate the proper version driver for UTM
          @logger.debug("Finding driver for UTM version: #{@version}")
          driver_map = {
            "4.5" => Version_4_5
          }

          # UTM 4.5.0 just doesn't work with Vagrant (https://github.com/utmapp/UTM/issues/5963),
          # so show error
          raise Errors::UtmInvalidVersion if @version.start_with?("4.5.0")

          driver_klass = nil
          driver_map.each do |key, klass|
            if @version.start_with?(key)
              driver_klass = klass
              break
            end
          end

          unless driver_klass
            supported_versions = driver_map.keys.sort.join(", ")
            raise Errors::UtmInvalidVersion,
                  supported_versions: supported_versions
          end

          @logger.info("Using UTM driver: #{driver_klass}")
          @driver = driver_klass.new(@uuid)

          return unless @uuid
          # Verify the VM exists, and if it doesn't, then don't worry
          # about it (mark the UUID as nil)
          raise VMNotFound unless @driver.vm_exists?(@uuid)
        end

        def_delegators :@driver,
                       :clear_forwarded_ports,
                       :forward_ports,
                       :import,
                       :list,
                       :read_forwarded_ports,
                       :read_network_interfaces,
                       :read_state,
                       :start,
                       :start_disposable,
                       :vm_exists?,
                       :halt,
                       :suspend,
                       :set_name,
                       :delete,
                       :execute_shell_command,
                       :execute_osa_script,
                       :check_qemu_guest_agent,
                       :read_guest_ip,
                       :last_uuid

        protected

        # This returns the version of UTM that is running.
        #
        # @return [String]
        def read_version
          # The version string is in the format "4.5.3"
          # Error: Can’t get application "UTM"
          # Success: "4.5.0"
          cmd = ["osascript", "-e", 'tell application "System Events" to return version of application "UTM"']
          output = execute_shell(*cmd)
          return output.strip unless output =~ /get application/

          raise Errors::UtmNotDetected
        end
      end
    end
  end
end
