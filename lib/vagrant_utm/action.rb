# frozen_string_literal: true

require "vagrant"
require "vagrant/action/builder"

module VagrantPlugins
  module Utm
    # Contains all the supported actions of the UTM provider.
    class Action
      # Include the built-in Vagrant action modules
      include Vagrant::Action::Builtin

      # Autoloading action blocks
      action_root = Pathname.new(File.expand_path("../action", __dir__))
      autoload :GetState, action_root.join("get_state")

      # Retrieves the state of the virtual machine.
      def self.action_get_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use GetState
        end
      end
    end
  end
end
