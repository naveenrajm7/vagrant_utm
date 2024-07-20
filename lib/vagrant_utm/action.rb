# frozen_string_literal: true

require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module Utm
    # Contains all the supported actions of the UTM provider.
    module Action
      # Include the built-in Vagrant action modules (e.g., DestroyConfirm)
      include Vagrant::Action::Builtin

      # Autoloading action blocks
      action_root = Pathname.new(File.expand_path("action", __dir__))
      autoload :Created, action_root.join("created")
      autoload :Destroy, action_root.join("destroy")
      autoload :GetState, action_root.join("get_state")
      autoload :ImportVM, action_root.join("import_vm")
      autoload :MessageAlreadyRunning, action_root.join("message_already_running")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :MessageNotRunning, action_root.join("message_not_running")
      autoload :MessageWillNotDestroy, action_root.join("message_will_not_destroy")
      autoload :Start, action_root.join("start")
      autoload :ForcedHalt, action_root.join("forced_halt")
      autoload :Suspend, action_root.join("suspend")
      autoload :Resume, action_root.join("resume")

      # Retrieves the state of the virtual machine.
      def self.action_get_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use GetState
        end
      end

      # This action starts a VM, assuming it is already imported and exists.
      # A precondition of this action is that the VM exists.
      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use Start
        end
      end

      # This is the action that is primarily responsible for completely
      # freeing the resources of the underlying virtual machine.
      # UTM equivalent of `utmctl delete <uuid>`
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, Created do |env1, b2|
            unless env1[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, DestroyConfirm do |env2, b3|
              if env2[:result]
                b3.use action_halt
                b3.use Destroy
              else
                b3.use MessageWillNotDestroy
              end
            end
          end
        end
      end

      # This actions brings up the virtual machine.
      # For now we start from UTM file
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          # Import UTM file to UTM app, through open with UTM
          b.use ImportVM
          # Start the VM
          b.use action_start
        end
      end

      # This action is primarily responsible for halting the VM.
      # UTM equivalent of `utmctl stop <uuid>`
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ForcedHalt
        end
      end

      # This action is primarily responsible for suspending the VM.
      # UTM equivalent of `utmctl suspend <uuid>`
      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use Suspend
        end
      end

      # This action is primarily responsible for resuming the VM.
      # UTM equivalent of `utmctl start <uuid>`
      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use Resume
        end
      end
    end
  end
end
