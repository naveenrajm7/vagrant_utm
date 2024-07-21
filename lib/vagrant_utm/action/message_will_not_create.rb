# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # Print VM will not be created message.
      class MessageWillNotCreate
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_utm.commands.up.will_not_create",
                               name: env[:machine].name)
          @app.call(env)
        end
      end
    end
  end
end
