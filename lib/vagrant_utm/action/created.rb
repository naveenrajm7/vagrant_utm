# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This class will set the result to be true if the machine is created.
      class Created
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # Set the result to be true if the machine is created.
          env[:result] = env[:machine].state.id != :not_created

          # Call the next if we have one (but we shouldn't, since this
          # middleware is built to run with the Call-type middlewares)
          @app.call(env)
        end
      end
    end
  end
end
