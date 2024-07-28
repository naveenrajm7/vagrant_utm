# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      class SnapshotRestore # rubocop:disable Style/Documentation
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t(
                          "vagrant.actions.vm.snapshot.restoring",
                          name: env[:snapshot_name]
                        ))
          env[:machine].provider.driver.restore_snapshot(
            env[:machine].id, env[:snapshot_name]
          )

          @app.call(env)
        end
      end
    end
  end
end
