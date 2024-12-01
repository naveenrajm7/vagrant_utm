# frozen_string_literal: true

module VagrantPlugins
  module Utm
    # Get All IP Adress of a machine.
    class IpAddress < Vagrant.plugin(2, :command)
      def execute
        with_target_vms do |machine|
          machine.action(:ip_address)
        end

        0
      end
    end
  end
end
