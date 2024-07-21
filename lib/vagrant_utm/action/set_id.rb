# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action destroys the running machine.
      class SetId
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:machine].id = env[:machine].provider.driver.last_uuid
          env[:ui].info I18n.t("vagrant_utm.messages.setting_id", id: env[:machine].id)
          @app.call(env)
        end
      end
    end
  end
end
