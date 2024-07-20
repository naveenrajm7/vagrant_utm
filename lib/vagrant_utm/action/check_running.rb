# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware checks that the VM is running, and raises an exception
      # if it is not, notifying the user that the VM must be running.
      # UTM equivalent status is "started"
      class CheckRunning
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          raise Vagrant::Errors::VMNotRunningError if env[:machine].state.id != :started

          @app.call(env)
        end
      end
    end
  end
end
