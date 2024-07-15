# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Errors
      # Base class for all errors raised by the UTM provider.
      class UtmError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_utm.errors")
      end

      # Error raised if the platform is not MacOS.
      class MacOSRequired < UtmError
        error_key(:macos_required)
      end

      # Error raised if the utmctl binary is not found.
      class UtmRequired < UtmError
        error_key(:utm_required)
      end

    end
  end
end
