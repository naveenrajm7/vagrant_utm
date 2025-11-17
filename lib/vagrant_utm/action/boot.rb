# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine.
      class Boot
        def initialize(app, _env)
          @app = app
        end

        def call(env) # rubocop:disable Metrics/AbcSize
          # Start up the VM and wait for it to boot.
          env[:ui].info I18n.t("vagrant.actions.vm.boot.booting")

          # Wait for AppleScript configuration changes to be fully saved
          # before attempting to start the VM to avoid OSStatus error -609
          # We retry the start command with exponential backoff if it fails
          max_retries = 3
          retry_count = 0
          retry_delay = 1

          max_retries.times do
            env[:machine].provider.driver.start
            break # Success, exit the loop
          rescue VagrantPlugins::Utm::Errors::UtmctlError => e
            # Only retry if it's an OSStatus error (configuration still being saved)
            raise unless e.message.include?("OSStatus")

            retry_count += 1

            # If we've exhausted all retries, re-raise the error
            raise if retry_count >= max_retries

            message = "VM configuration may still be saving. Retrying in #{retry_delay} seconds... " \
                      "(#{retry_count}/#{max_retries})"
            env[:ui].warn message
            sleep retry_delay
            retry_delay *= 2 # Exponential backoff: 1s, 2s, 4s
          end

          @app.call(env)
        end
      end
    end
  end
end
