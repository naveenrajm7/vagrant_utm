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

        def import(env) # rubocop:disable Metrics/AbcSize
          env[:ui].info I18n.t("vagrant.actions.vm.import.importing",
                               name: env[:machine].box.name)

          # Import the virtual machine
          utm_file = env[:machine].box.directory.join("box.utm").to_s
          id = env[:machine].provider.driver.import(utm_file) do |progress|
            env[:ui].rewriting do |ui|
              ui.clear_line
              ui.report_progress(progress, 100, false)
            end
          end

          # Set the machine ID
          env[:machine_id] = id
          env[:machine].id = id unless env[:skip_machine]

          # Clear the line one last time since the progress meter doesn't disappear
          # immediately.
          env[:ui].clear_line

          # If we got interrupted, then the import could have been
          # interrupted and its not a big deal. Just return out.
          return if env[:interrupted]

          # Flag as erroneous and return if import failed
          raise Vagrant::Errors::VMImportFailure unless id

          # Import completed successfully. Continue the chain
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
