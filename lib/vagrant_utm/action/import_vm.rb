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

          # Set the UID of Vagrant machine to the Name of the VM in UTM (same as name in Vagrantfile config)
          # UTM maintains UUID as primary key for VMs, but even the name works for all commands
          # However, name is not unique.
          # TODO: Decide if we want to use UTM 'UUID' or 'Name' for Vagrant machine ID

          # For now we are using the 'Name' as the machine ID
          machine.id = name

          @app.call(env)
        end
      end
    end
  end
end
