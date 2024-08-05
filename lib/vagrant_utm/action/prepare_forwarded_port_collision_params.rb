# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware class is responsible for preparing forwarded port
      class PrepareForwardedPortCollisionParams
        def initialize(app, _env)
          @app = app
        end

        def call(env) # rubocop:disable Metrics/AbcSize
          # Get the forwarded ports used by other virtual machines and
          # consider those in use as well.
          env[:port_collision_extra_in_use] = env[:machine].provider.driver.read_used_ports

          # Build the remap for any existing collision detections
          remap = {}
          env[:port_collision_remap] = remap
          env[:machine].provider.driver.read_forwarded_ports.each do |_nic, name, hostport, _guestport|
            env[:machine].config.vm.networks.each do |type, options|
              next if type != :forwarded_port

              # UTM port forwarding does not have name field
              # We use the host port as the name (key) since that is what is unique
              # If the host port matches the name(host port) of the forwarded port, then
              # remap.
              if options[:host] == name
                remap[options[:host]] = hostport
                break
              end
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
