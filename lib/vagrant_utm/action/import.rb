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

        def recover(env)
          return unless env[:machine] && env[:machine].state.id != Vagrant::MachineState::NOT_CREATED_ID
          return if env["vagrant.error"].is_a?(Vagrant::Errors::VagrantError)

          # If we're not supposed to destroy on error then just return
          return unless env[:destroy_on_error]

          # Interrupted, destroy the VM. We note that we don't want to
          # validate the configuration here, and we don't want to confirm
          # we want to destroy.
          destroy_env = env.clone
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true

          # We don't want to double-execute any hooks attached to
          # machine_action_up. Instead we should be honoring destroy hooks.
          # Changing the action name here should make the Builder do the
          # right thing.
          destroy_env[:raw_action_name] = :destroy
          destroy_env[:action_name] = :machine_action_destroy
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end
      end
    end
  end
end
