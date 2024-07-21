# frozen_string_literal: true

require "log4r"

module VagrantPlugins
  module Utm
    module Action
      # This action checks if the guest additions are installed.
      # Currently only check's if qemu-guest-agent is installed and running.
      # TODO: Add other checks, Drivers(eg Virt), SPICE Agent, SPICE WebDAV, VirtFS
      class CheckGuestAdditions
        def initialize(app, _env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_utm::action::check_guest_additions")
        end

        def call(env) # rubocop:disable Metrics/AbcSize
          unless env[:machine].provider_config.check_guest_additions
            @logger.info("Not checking guest additions because configuration")
            return @app.call(env)
          end

          env[:ui].output(I18n.t("vagrant_utm.utm.checking_guest_additions"))

          if env[:machine].provider.driver.check_qemu_guest_agent
            env[:ui].detail(I18n.t("vagrant_utm.actions.vm.check_guest_additions.detected"))
          else
            env[:ui].detail(I18n.t("vagrant_utm.actions.vm.check_guest_additions.not_detected"))
          end

          # Continue
          @app.call(env)
        end
      end
    end
  end
end
