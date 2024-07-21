# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Errors
      # Base class for all errors raised by the UTM provider.
      class UtmError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_utm.errors")
      end

      # This error is raised if the platform is not MacOS.
      class MacOSRequired < UtmError
        error_key(:macos_required)
      end

      # This error is raised if the UTM is not found.
      class UtmRequired < UtmError
        error_key(:utm_required)
      end

      # This error is raised if the utmctl is not found.
      class UtmctlNotFoundError < UtmError
        error_key(:utmctl_not_found)
      end

      # This error is raised if the utmctl command fails.
      class UtmctlError < UtmError
        error_key(:utmctl_error)
      end

      # This error is raised if a shell/osascript command fails.
      class CommandError < UtmError
        error_key(:command_error)
      end

      # This error is raised if UTM file was failed to import.
      class UTMImportFailed < UtmError
        error_key(:utm_import_failed)
      end

      # This error is raised if the virtual machine is not created
      class InstanceNotCreatedError < UtmError
        error_key(:instance_not_created)
      end

      # This error is raised if the virtual machine is not running
      class InstanceNotRunningError < UtmError
        error_key(:instance_not_running)
      end
    end
  end
end
