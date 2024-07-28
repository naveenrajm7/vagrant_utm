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
      class UtmNotDetected < UtmError
        error_key(:utm_not_detected)
      end

      # This error is raised if the UTM version is not supported.
      class UtmInvalidVersion < UtmError
        error_key(:utm_invalid_version)
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
      class UtmImportFailed < UtmError
        error_key(:utm_import_failed)
      end

      # This error is raised if invalid protocol is used in forwarded ports.
      class ForwardedPortInvalidProtocol < UtmError
        error_key(:forwarded_port_invalid_protocol)
      end

      # This error is raised if the qemu-img is not detected.
      class QemuImgRequired < UtmError
        error_key(:qemu_img_required)
      end

      # This error is raised if the snapshot command failed.
      class SnapShotCommandFailed < UtmError
        error_key(:snapshot_command_failed)
      end

      # This error is raised if multiple VM files are found during snapshot.
      class SnapShotMultipleVMFiles < UtmError
        error_key(:snapshot_multiple_vm_files)
      end

      # This error is raised if the VM is not found.
      class SnapShotVMFileNotFound < UtmError
        error_key(:snapshot_vm_file_not_found)
      end
    end
  end
end
