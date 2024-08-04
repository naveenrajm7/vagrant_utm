# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action imports the virtual machine to UTM.
      class Import
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

          env[:ui].info I18n.t("vagrant_utm.messages.importing_utm_file", name: utm_file_url)

          # Import the UTM VM file
          driver.import(utm_file_url)

          # Set the UID of Vagrant machine to the UUID of the VM in UTM.
          # UTM maintains UUID as primary key for VMs, but even the name works for all commands
          # However, name is not unique.

          # So we set the machine.id to UUID in next step after import.
          # TODO: Set the machine.id to UUID after import returns the UUID (yet to be supported by UTM).
          # machine.id = return value of import

          @app.call(env)
        end
      end
    end
  end
end
