# frozen_string_literal: true

require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module Utm
    # Contains all the supported actions of the UTM provider.
    module Action # rubocop:disable Metrics/ModuleLength
      # Autoloading action blocks
      action_root = Pathname.new(File.expand_path("action", __dir__))
      autoload :CheckAccessible, action_root.join("check_accessible")
      autoload :CheckCreated, action_root.join("check_created")
      autoload :CheckGuestAdditions, action_root.join("check_guest_additions")
      autoload :CheckRunning, action_root.join("check_running")
      autoload :CheckUtm, action_root.join("check_utm")
      autoload :Created, action_root.join("created")
      autoload :Customize, action_root.join("customize")
      autoload :Destroy, action_root.join("destroy")
      autoload :DownloadConfirm, action_root.join("download_confirm")
      autoload :Export, action_root.join("export")
      autoload :ImportVM, action_root.join("import_vm")
      autoload :MessageAlreadyRunning, action_root.join("message_already_running")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageNotRunning, action_root.join("message_not_running")
      autoload :MessageWillNotCreate, action_root.join("message_will_not_create")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :SetId, action_root.join("set_id")
      autoload :Start, action_root.join("start")
      autoload :ForcedHalt, action_root.join("forced_halt")
      autoload :Suspend, action_root.join("suspend")
      autoload :Resume, action_root.join("resume")

      # Include the built-in Vagrant action modules (e.g., DestroyConfirm)
      include Vagrant::Action::Builtin

      # State of VM is given by Driver read state

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
      # UTM equivalent of `utmctl stop <uuid>`
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm
          b.use Call, Created do |env, b2|
            if env[:result]
              b2.use CheckAccessible
              b2.use ForcedHalt
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
            # REMOVE: TEST: using this action to test development actions
            b2.use CheckGuestAdditions
            b2.use Export
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
              b2.use Resume
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
          b.use Start
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
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckUtm

          b.use Call, Created do |env1, b2|
            # If the VM is NOT created yet, then do the setup steps
            unless env1[:result]
              # load UTM file to UTM app, through 'utm://downloadVM?url='
              b2.use ImportVM

              b2.use Call, DownloadConfirm do |env2, b3|
                if env2[:result]
                  # SetID
                  b3.use SetId
                  # Customize
                  b3.use Customize, "pre-boot"
                else
                  b3.use MessageWillNotCreate
                  raise Errors::UTMImportFailed
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
