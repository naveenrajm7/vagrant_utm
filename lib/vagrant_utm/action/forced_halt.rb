# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action is responsible for halting (stopping) the VM.
      class ForcedHalt
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          current_state = env[:machine].state.id
          if current_state == :started
            env[:ui].info I18n.t("vagrant.actions.vm.halt.force")
            env[:machine].provider.driver.halt
          end

          # Sleep for a second to verify that the VM properly
          # cleans itself up. Silly VirtualBox.
          sleep 1 unless env["vagrant.test"]

          @app.call(env)
        end
      end
    end
  end
end
