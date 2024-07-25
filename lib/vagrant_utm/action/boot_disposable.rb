# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine in disposable mode.
      class BootDisposable
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # Start up the VM in disposable mode.
          env[:ui].warn I18n.t("vagrant_utm.actions.vm.boot.disposable")
          env[:machine].provider.driver.start_disposable

          @app.call(env)
        end
      end
    end
  end
end
