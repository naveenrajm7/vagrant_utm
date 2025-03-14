# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Model
      # Represents a single forwarded port for UTM. This has various
      # helpers and defaults for a forwarded port.
      class ForwardedPort
        # The 'Emulated VLAN' adapter on which to attach the forwarded port.
        #
        # @return [Integer]
        attr_reader :adapter

        # If true, this port should be auto-corrected.
        # TODO: This is not implemented yet.
        # @return [Boolean]
        attr_reader :auto_correct

        # The unique ID for the forwarded port.
        #
        # @return [String]
        attr_reader :id

        # The protocol to forward.
        #
        # @return [String]
        attr_reader :protocol

        # The IP that the forwarded port will connect to on the guest machine.
        #
        # @return [String]
        attr_reader :guest_ip

        # The port on the guest to be exposed on the host.
        #
        # @return [Integer]
        attr_reader :guest_port

        # The IP that the forwarded port will bind to on the host machine.
        #
        # @return [String]
        attr_reader :host_ip

        # The port on the host used to access the port on the guest.
        #
        # @return [Integer]
        attr_reader :host_port

        def initialize(id, host_port, guest_port, options)
          @id         = id
          @guest_port = guest_port
          @host_port  = host_port

          options ||= {}
          @auto_correct = false
          @auto_correct = options[:auto_correct] if options.key?(:auto_correct)
          # if adapter is not set, use index 1 (Emulated VLAN).
          # index 0 is the default adapter (Shared Network)
          @adapter  = (options[:adapter] || 1).to_i
          @guest_ip = options[:guest_ip] || nil
          @host_ip = options[:host_ip] || nil
          @protocol = options[:protocol] || "tcp" # default to TCP
        end

        # This corrects the host port and changes it to the given new port.
        # TODO: This is not implemented yet.
        # @param [Integer] new_port The new port
        def correct_host_port(new_port)
          @host_port = new_port
        end
      end
    end
  end
end
