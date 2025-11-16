# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to start the virtual machine.
      class Boot
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # Start up the VM and wait for it to boot.
          env[:ui].info I18n.t("vagrant.actions.vm.boot.booting")
          
          # Wait for AppleScript configuration changes to be fully saved
          # before attempting to start the VM to avoid OSStatus error -609
          # We retry the start command with exponential backoff if it fails
          max_retries = 3
          retry_count = 0
          retry_delay = 1
          
          loop do
            begin
              env[:machine].provider.driver.start
              break # Success, exit the loop
            rescue VagrantPlugins::Utm::Errors::UtmctlError => e
              # Check if it's an OSStatus error (configuration still being saved)
              if e.message.include?("OSStatus") && retry_count < max_retries
                retry_count += 1
                env[:ui].warn "VM configuration may still be saving. Retrying in #{retry_delay} seconds... (#{retry_count}/#{max_retries})"
                sleep retry_delay
                retry_delay *= 2 # Exponential backoff: 1s, 2s, 4s
              else
                # Re-raise the error if it's not an OSStatus error or we've exhausted retries
                raise
              end
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
