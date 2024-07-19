# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action is responsible for suspending the VM.
      class Suspend
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          if env[:machine].state.id == :started
            env[:ui].info I18n.t("vagrant.actions.vm.suspend.suspending")
            env[:machine].provider.driver.suspend
          end

          @app.call(env)
        end
      end
    end
  end
end
