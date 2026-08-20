# frozen_string_literal: true

require File.expand_path("version_4_7", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 5.0.x
      class Version_5_0 < Version_4_7 # rubocop:disable Naming/ClassAndModuleCamelCase
        # UTM AppleScript VLAN network properties land in 5.0.4
        # (utmapp/UTM#7710).
        VLAN_NETWORK_MIN_VERSION = "5.0.4"
        NETWORK_OPTION_FLAGS = {
          vlan_guest_address: "--vlan-guest-address",
          vlan_guest_address_ipv6: "--vlan-guest-address-ipv6",
          vlan_dhcp_start_address: "--vlan-dhcp-start-address",
          vlan_dhcp_end_address: "--vlan-dhcp-end-address"
        }.freeze

        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_5_0")
        end

        # Update VLAN / DHCP settings on a network interface.
        #
        # These properties apply to shared/host network modes and map to the
        # AppleScript fields added in utmapp/UTM#7710 (UTM 5.0.4+).
        #
        # @param [Integer] index Network interface index (0-based)
        # @param [Hash] options
        # @option options [String] :vlan_guest_address IPv4 subnet CIDR
        # @option options [String] :vlan_guest_address_ipv6 IPv6 prefix
        # @option options [String] :vlan_dhcp_start_address DHCP pool start
        # @option options [String] :vlan_dhcp_end_address DHCP pool end
        # @option options [Boolean] :isolate_from_host Isolate guest from host
        def update_network_interface(index, options = {})
          require_vlan_network_support!(__method__)

          args = ["--index", index.to_s] + network_option_arguments(options)

          if args.length == 2
            raise ArgumentError,
                  "update_network_interface requires at least one network option"
          end

          command = ["update_network_interface.applescript", @uuid] + args
          execute_osa_script(command)
        end

        private

        def network_option_arguments(options)
          NETWORK_OPTION_FLAGS.flat_map do |key, flag|
            option_argument(flag, options[key])
          end + isolate_from_host_argument(options[:isolate_from_host])
        end

        def option_argument(flag, value)
          return [] if value.nil? || value.to_s.empty?

          [flag, value.to_s]
        end

        def isolate_from_host_argument(value)
          return [] if value.nil?

          ["--isolate-from-host", value ? "true" : "false"]
        end

        def require_vlan_network_support!(method_name)
          version = read_utm_version
          return if Gem::Version.new(version) >= Gem::Version.new(VLAN_NETWORK_MIN_VERSION)

          raise Errors::UtmInvalidVersion,
                supported_versions: "#{VLAN_NETWORK_MIN_VERSION}+ " \
                                    "(required for #{method_name})"
        end

        def read_utm_version
          @read_utm_version ||= begin
            cmd = ["osascript", "-e",
                   'tell application "System Events" to return version of application "UTM"']
            execute_shell(*cmd).strip
          end
        end
      end
    end
  end
end
