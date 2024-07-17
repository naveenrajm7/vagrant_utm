# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action imports the virtual machine.
      class ImportVM
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          config = machine.provider_config
          driver = machine.provider.driver
          utm_file = config.utm_file

          driver.import(utm_file)

          @app.call(env)
        end
      end
    end
  end
end
