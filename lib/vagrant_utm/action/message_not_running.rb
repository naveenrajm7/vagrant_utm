# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # Print VM not running message.
      class MessageNotRunning
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.commands.common.vm_not_running")
          @app.call(env)
        end
      end
    end
  end
end
