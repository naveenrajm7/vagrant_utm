# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action is responsible for resuming the VM.
      class Resume
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          current_state = env[:machine].state.id
          if current_state == :paused
            env[:ui].info I18n.t("vagrant.actions.vm.resume.unpausing")
            env[:machine].provider.driver.start
          end

          @app.call(env)
        end
      end
    end
  end
end
