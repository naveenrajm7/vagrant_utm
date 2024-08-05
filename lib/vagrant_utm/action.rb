# frozen_string_literal: true

require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module Utm
    # Contains all the supported actions of the UTM provider.
    module Action # rubocop:disable Metrics/ModuleLength
      # Autoloading action blocks
      action_root = Pathname.new(File.expand_path("action", __dir__))
      autoload :Boot, action_root.join("boot")
      autoload :BootDisposable, action_root.join("boot_disposable")
      autoload :CheckAccessible, action_root.join("check_accessible")
      autoload :CheckCreated, action_root.join("check_created")
      autoload :CheckGuestAdditions, action_root.join("check_guest_additions")
      autoload :CheckQemuImg, action_root.join("check_qemu_img")
      autoload :CheckRunning, action_root.join("check_running")
      autoload :CheckUtm, action_root.join("check_utm")
      autoload :ClearForwardedPorts, action_root.join("clear_forwarded_ports")
      autoload :Created, action_root.join("created")
      autoload :Customize, action_root.join("customize")
      autoload :Destroy, action_root.join("destroy")
      autoload :DownloadConfirm, action_root.join("download_confirm")
      autoload :Export, action_root.join("export")
      autoload :ForcedHalt, action_root.join("forced_halt")
      autoload :ForwardPorts, action_root.join("forward_ports")
      autoload :Import, action_root.join("import")
      autoload :IsPaused, action_root.join("is_paused")
      autoload :IsRunning, action_root.join("is_running")
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :MessageAlreadyRunning, action_root.join("message_already_running")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageNotRunning, action_root.join("message_not_running")
      autoload :MessageNotStopped, action_root.join("message_not_stopped")
      autoload :MessageWillNotCreate, action_root.join("message_will_not_create")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :PrepareForwardedPortCollisionParams, action_root.join("prepare_forwarded_port_collision_params")
      autoload :Resume, action_root.join("resume")
      autoload :SetId, action_root.join("set_id")
      autoload :SetName, action_root.join("set_name")
      autoload :SnapshotDelete, action_root.join("snapshot_delete")
      autoload :SnapshotRestore, action_root.join("snapshot_restore")
      autoload :SnapshotSave, action_root.join("snapshot_save")
      autoload :Suspend, action_root.join("suspend")
      autoload :WaitForRunning, action_root.join("wait_for_running")

      # Include the built-in Vagrant action modules (e.g., DestroyConfirm)
      include Vagrant::Action::Builtin

      # State of VM is given by Driver read state

      # This action boots the VM, assuming the VM is in a state that requires
      # a bootup (i.e. not saved).
      def self.action_boot # rubocop:disable Metrics/AbcSize
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckAccessible
          b.use SetName
          b.use ClearForwardedPorts
          b.use Provision
          b.use EnvSet, port_collision_repair: true
          b.use PrepareForwardedPortCollisionParams
          b.use HandleForwardedPortCollisions
          b.use ForwardPorts
          b.use SetHostname
          b.use Customize, "pre-boot"
          b.use Boot
          b.use Customize, "post-boot"
          # WaitForCommunicator reads machine ssh_info.
          # Our ssh_info returns nil if machine is not 'started'
          # if 'started' we query the guest machine for IP address.
          # But after 'started' it takes some time for the machine to be 'running'
          # we need to wait for the machine to be 'running' before we can query
          # but UTM does not report a 'running' state (machine ready to take commands)
          # If you put wait in the function ssh_info, which is called muliple timmes
          # we wait every time we call ssh_info, which is not good.
          # So we wait here , after boot, before we can query the machine.
          b.use WaitForRunning
          # Machine need to be up and running before we can query
          # add valid states to starting, started, running (after UTM provides running state)
          b.use WaitForCommunicator, %i[starting started]
          b.use Customize, "post-comm"
          b.use CheckGuestAdditions
        end
      end

      # This is the action that is primarily responsible for completely
      # freeing the resources of the underlying virtual machine.
      # UTM equivalent of `utmctl delete <uuid>`
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env1, b2|
            unless env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, DestroyConfirm do |env2, b3|
              if env2[:result]
                b3.use ConfigValidate
                b3.use ProvisionerCleanup, :before
                b3.use CheckAccessible
                b3.use action_halt
                b3.use Destroy
              else
                b3.use MessageWillNotDestroy
              end
            end
          end
        end
      end

      # This action is primarily responsible for halting the VM.
      # gracefully or by force.
      # UTM equivalent of `utmctl stop <uuid>`
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible

              # if VM is paused, resume it before halting
              # utmctl stop will not work on paused VM
              b2.use Call, IsPaused do |env2, b3|
                next unless env2[:result]

                b3.use Resume
              end

              b2.use Call, GracefulHalt, :stopped, :started do |env2, b3|
                b3.use ForcedHalt unless env2[:result]
              end
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      # This action packages the virtual machine into a single box file.
      def self.action_package
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use CheckAccessible
            b2.use action_halt
            b2.use ClearForwardedPorts
            b2.use Export
          end
        end
      end

      # This action just runs the provisioners on the machine.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use ConfigValidate
          b.use Call, Created do |env1, b2|
            unless env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use CheckAccessible
              b3.use Provision
            end
          end
        end
      end

      # This action is responsible for reloading the machine, which
      # brings it down, sucks in new configuration, and brings the
      # machine back up with the new configuration.
      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env1, b2|
            unless env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConfigValidate
            b2.use action_halt
            b2.use action_start
          end
        end
      end

      # This action is primarily responsible for resuming the suspended VM.
      # UTM equivalent of `utmctl start <uuid>`
      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use EnvSet, port_collision_repair: false
              b2.use PrepareForwardedPortCollisionParams
              b2.use HandleForwardedPortCollisions
              b2.use Resume
              b2.use Provision
              b2.use WaitForRunning
              b2.use WaitForCommunicator, %i[resuming started]
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      # This is the action that is primarily responsible for deleting a snapshot
      def self.action_snapshot_delete
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use CheckQemuImg
          b.use Call, Created do |env, b2|
            if env[:result]
              # qemu-img needs write-lock to file, so VM should be stopped
              b2.use Call, IsStopped do |env2, b3|
                if env2[:result]
                  b3.use SnapshotDelete
                else
                  b3.use MessageNotStopped
                end
              end
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      # This is the action that is primarily responsible for restoring a snapshot
      def self.action_snapshot_restore # rubocop:disable Metrics/AbcSize
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use CheckQemuImg
          b.use Call, Created do |env, b2|
            raise Vagrant::Errors::VMNotCreatedError unless env[:result]

            b2.use CheckAccessible
            b2.use EnvSet, force_halt: true
            b2.use action_halt
            b2.use SnapshotRestore

            b2.use Call, IsEnvSet, :snapshot_delete do |env2, b3|
              b3.use action_snapshot_delete if env2[:result]
            end

            b2.use Call, IsEnvSet, :snapshot_start do |env2, b3|
              b3.use action_start if env2[:result]
            end
          end
        end
      end

      # This is the action that is primarily responsible for saving a snapshot
      def self.action_snapshot_save
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use CheckQemuImg
          b.use Call, Created do |env, b2|
            if env[:result]
              # qemu-img does offline snapshot, so VM should be stopped
              b2.use Call, IsStopped do |env2, b3|
                if env2[:result]
                  b3.use SnapshotSave
                else
                  b3.use MessageNotStopped
                end
              end
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      # This is the action that will exec into an SSH shell.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use CheckCreated
          b.use CheckAccessible
          b.use CheckRunning
          b.use SSHExec
        end
      end

      # This is the action that will run a single SSH command.
      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use CheckCreated
          b.use CheckAccessible
          b.use CheckRunning
          b.use SSHRun
        end
      end

      # This action starts a VM, assuming it is already imported and exists.
      # A precondition of this action is that the VM exists.
      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use ConfigValidate
          b.use Call, IsRunning do |env, b2|
            # If the VM is running, run the necessary provisioners
            if env[:result]
              b2.use action_provision
              next
            end

            b2.use Call, IsPaused do |env2, b3|
              if env2[:result]
                b3.use Resume
                next
              end

              # The VM is not paused, so we must have to boot it up
              # like normal. Boot!
              b3.use action_boot
            end
          end
        end
      end

      # This action start VM in disposable mode.
      # UTM equivalent of `utmctl start <uuid> --disposable`
      def self.action_start_disposable
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use ConfigValidate
          b.use Call, IsRunning do |env1, b2|
            if env1[:result]
              b2.use MessageAlreadyRunning
              next
            end
            # If the VM is NOT running, then start in disposable mode
            b2.use BootDisposable
          end
        end
      end

      # This action is primarily responsible for suspending the VM.
      # UTM equivalent of `utmctl suspend <uuid>`
      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use Suspend
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      # This action brings the machine up from nothing, including importing
      # the UTM file, configuring metadata, and booting.
      def self.action_up # rubocop:disable Metrics/AbcSize
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use ConfigValidate
          b.use Call, Created do |env, b2|
            # If the VM is NOT created yet, then do the setup steps
            unless env[:result]
              b2.use CheckAccessible
              b2.use Customize, "pre-import"
              # load UTM file to UTM app, through 'utm://downloadVM?url='
              b2.use Import

              b2.use Call, DownloadConfirm do |env1, b3|
                if env1[:result]
                  # SetID
                  b3.use SetId
                  b3.use SetName
                  # Customize
                  b3.use Customize, "pre-boot"
                else
                  b3.use MessageWillNotCreate
                  raise Errors::UtmImportFailed
                end
              end
            end
          end

          # Start the VM
          b.use action_start
        end
      end
    end
  end
end
