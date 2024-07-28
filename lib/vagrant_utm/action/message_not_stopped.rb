# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # Print VM not stopped message.
      class MessageNotStopped
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_utm.commands.common.vm_not_stopped")
          @app.call(env)
        end
      end
    end
  end
end
