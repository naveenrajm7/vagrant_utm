# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action retrieves the state of the virtual machine.
      class GetState
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          config = machine.provider_config
          driver = machine.provider.driver
          name = config.name

          list = driver.list
          instance = list.find(name)

          env[:machine_state_id] = instance.nil? ? :not_created : instance.vagrant_state
          @app.call(env)
        end
      end
    end
  end
end
