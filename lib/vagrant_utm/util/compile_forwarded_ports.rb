# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "vagrant/util/scoped_hash_override"

module VagrantPlugins
  module Utm
    module Util
      # This module contains the code to compile the forwarded ports from config.
      module CompileForwardedPorts
        include Vagrant::Util::ScopedHashOverride

        # This method compiles the forwarded ports into {ForwardedPort}
        # models.
        def compile_forwarded_ports(config) # rubocop:disable Metrics/AbcSize
          mappings = {}

          config.vm.networks.each do |type, options|
            next unless type == :forwarded_port

            guest_port = options[:guest]
            host_port  = options[:host]
            host_ip    = options[:host_ip]
            protocol   = options[:protocol] || "tcp"
            options    = scoped_hash_override(options, :utm)
            id         = options[:id]

            # If the forwarded port was marked as disabled, ignore.
            next if options[:disabled]

            key = "#{host_ip}#{protocol}#{host_port}"
            mappings[key] =
              Model::ForwardedPort.new(id, host_port, guest_port, options)
          end

          mappings.values
        end
      end
    end
  end
end
