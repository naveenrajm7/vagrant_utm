# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Run VM as a snapshot and do not save changes to disk.
    class Disposable < Vagrant.plugin(2, :command)
      def execute
        with_target_vms do |machine|
          machine.action(:start_disposable)
        end

        0
      end
    end
  end
end
