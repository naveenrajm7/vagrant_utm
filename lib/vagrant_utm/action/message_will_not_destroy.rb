# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # Print VM will not be destroyed message.
      class MessageWillNotDestroy
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.commands.destroy.will_not_destroy",
                               name: env[:machine].name)
          @app.call(env)
        end
      end
    end
  end
end
