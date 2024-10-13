# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "vagrant/action/general/package"

module VagrantPlugins
  module Utm
    module Action
      # This action packages the virtual machine into a box
      class Package < Vagrant::Action::General::Package
        # Doing this so that we can test that the parent is properly
        # called in the unit tests.
        alias general_call call
        def call(env)
          general_call(env)
        end
      end
    end
  end
end
