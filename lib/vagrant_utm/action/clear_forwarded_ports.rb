# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This action clears forwarded ports on the UTM VM.
      class ClearForwardedPorts
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          unless env[:machine].provider.driver.read_forwarded_ports.empty?
            env[:ui].info I18n.t("vagrant.actions.vm.clear_forward_ports.deleting")
            env[:machine].provider.driver.clear_forwarded_ports
          end

          @app.call(env)
        end
      end
    end
  end
end
