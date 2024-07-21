# frozen_string_literal: true

require "vagrant/action/builtin/confirm"

module VagrantPlugins
  module Utm
    module Action
      # Action to confirm download of UTM.
      class DownloadConfirm < Vagrant::Action::Builtin::Confirm
        def initialize(app, env)
          force_key = nil # No force key, user must confirm the download
          message = I18n.t("vagrant_utm.messages.download_confirmation",
                           name: env[:machine].provider_config.utm_file_url)
          super(app, env, message, force_key, allowed: %w[y n Y N])
        end
      end
    end
  end
end
