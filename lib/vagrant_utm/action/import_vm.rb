# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action imports the virtual machine to UTM.
      class ImportVM
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          import(env)
        end

        def import(env)
          machine = env[:machine]
          config = machine.provider_config
          driver = machine.provider.driver
          utm_file_url = config.utm_file_url
          name = config.name

          env[:ui].info I18n.t("vagrant_utm.messages.importing_utm_file", name: utm_file_url)

          # Import the UTM VM file
          uuid = driver.import(utm_file_url)
          # Configure the VM, change the name (required) and settings (if needed).
          driver.configure(uuid, config)

          # Set the UID and Name of the machine for vagrant
          # machine does not have uid (Need to store else where)
          # machine.uid = uuid
          machine.id = name

          @app.call(env)
        end
      end
    end
  end
end
