# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This action deletes a snapshot of the machine.
      class SnapshotDelete
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t(
                          "vagrant.actions.vm.snapshot.deleting",
                          name: env[:snapshot_name]
                        ))
          env[:machine].provider.driver.delete_snapshot(
            env[:machine].id, env[:snapshot_name]
          )

          env[:ui].success(I18n.t(
                             "vagrant.actions.vm.snapshot.deleted",
                             name: env[:snapshot_name]
                           ))

          @app.call(env)
        end
      end
    end
  end
end
