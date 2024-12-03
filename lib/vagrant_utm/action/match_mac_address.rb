# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This action matches the MAC address of the virtual machine to the
      # configured MAC address in the Vagrantfile.
      # OR generates a new MAC address if none is set.
      # This is useful to make sure that different virtual machines
      # have different MAC addresses.
      class MatchMACAddress
        def initialize(app, _env)
          @app = app
        end

        def call(env) # rubocop:disable Metrics/AbcSize
          base_mac = env[:machine].config.vm.base_mac
          # If we have a base MAC address and not is empty (empty in some default Vagranfile)
          # then we use that to match
          if base_mac && !base_mac.empty?
            # Create the proc which we want to use to modify the virtual machine
            env[:ui].info I18n.t("vagrant.actions.vm.match_mac.matching")
            env[:machine].provider.driver.set_mac_address(env[:machine].config.vm.base_mac)
          else
            env[:ui].info I18n.t("vagrant.actions.vm.match_mac.generating")
            env[:machine].provider.driver.set_mac_address(nil)
          end

          @app.call(env)
        end
      end
    end
  end
end
