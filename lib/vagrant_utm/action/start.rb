# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine.
      class Start
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:machine].provider.driver.start

          @app.call(env)
        end
      end
    end
  end
end
