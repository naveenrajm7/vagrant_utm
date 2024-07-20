# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This action destroys the running machine.
      class Destroy
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.actions.vm.destroy.destroying")
          env[:machine].provider.driver.delete
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
