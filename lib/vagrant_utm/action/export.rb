# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action destroys the running machine.
      class Export
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # UTM 'Share' feature in UI will Export the virtual machine and all its data.
          # Till 'Share' is exposed via API, show a message to manually export.
          env[:ui].info I18n.t("vagrant_utm.actions.vm.export.manual_exporting",
                               name: env[:machine].provider_config.name)
          @app.call(env)
        end
      end
    end
  end
end
