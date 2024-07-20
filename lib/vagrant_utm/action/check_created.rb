# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware checks that the VM is created, and raises an exception
      # if it is not, notifying the user that creation is required.
      class CheckCreated
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          raise Vagrant::Errors::VMNotCreatedError if env[:machine].state.id == :not_created

          @app.call(env)
        end
      end
    end
  end
end
