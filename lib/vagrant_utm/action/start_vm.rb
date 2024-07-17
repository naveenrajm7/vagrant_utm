# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine.
      class StartVM
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          config = machine.provider_config
          driver = machine.provider.driver
          name = config.name

          # check if exists
          # list = driver.list
          # return @app.call(env) unless list.any?(name)

          # # check if running
          # instance = driver.get(name)
          # return @app.call(env) if instance.nil? || instance.vagrant_state == :running

          # Start the VM
          driver.start(name)

          @app.call(env)
        end
      end
    end
  end
end
