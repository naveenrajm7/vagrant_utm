# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine.
      class Boot
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # Start up the VM and wait for it to boot.
          env[:ui].info I18n.t("vagrant.actions.vm.boot.booting")
          env[:machine].provider.driver.start

          @app.call(env)
        end
      end
    end
  end
end
