# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware checks if the machine is running (UTM started) and sets the result.
      class IsRunning
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # Set the result to be true if the machine is running.
          env[:result] = env[:machine].state.id == :started

          # Call the next if we have one (but we shouldn't, since this
          # middleware is built to run with the Call-type middlewares)
          @app.call(env)
        end
      end
    end
  end
end
