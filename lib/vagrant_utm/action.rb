# frozen_string_literal: true

require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module Utm
    # Contains all the supported actions of the UTM provider.
    module Action
      # Include the built-in Vagrant action modules
      include Vagrant::Action::Builtin

      # Autoloading action blocks
      action_root = Pathname.new(File.expand_path("action", __dir__))
      autoload :GetState, action_root.join("get_state")
      autoload :ImportVM, action_root.join("import_vm")
      autoload :StartVM, action_root.join("start_vm")
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
          b.use StartVM
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
