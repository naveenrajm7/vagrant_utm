# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action waits for a given amount of seconds.
      # This is a workaround for the UTM provider, which does not
      # report when the VM is running. As soon as UTM reports the
      # state as 'running', this action can and will be removed.
      # Then we use the state 'running', rather than 'started'
      class WaitForRunning
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          # set the wait time to user configured time or
          # default time.
          wait_time = env[:machine].provider_config.wait_time
          env[:ui].info I18n.t("vagrant_utm.messages.waiting_for_vm", time: wait_time)
          sleep(wait_time)

          @app.call(env)
        end
      end
    end
  end
end
