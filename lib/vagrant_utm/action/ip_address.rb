# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # Action to get IP address of machine.
      class IpAddress
        def initialize(app, _env)
          @app = app
        end

        def call(env) # rubocop:disable Metrics/AbcSize
          # Get IP address of the machine.
          env[:ui].warn I18n.t("vagrant_utm.actions.vm.ip_address.reading")
          guest_ips = env[:machine].provider.driver.read_guest_ip

          if guest_ips.empty?
            # Inform user that no IP address was found.
            env[:ui].warn I18n.t("vagrant_utm.actions.vm.ip_address.not_found")
          else
            # Show IP address of the machine.
            env[:ui].info I18n.t("vagrant_utm.actions.vm.ip_address.show")
            guest_ips.each do |ip|
              env[:ui].info "  #{ip}"
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
