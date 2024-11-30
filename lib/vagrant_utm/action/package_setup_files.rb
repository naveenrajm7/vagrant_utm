# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "vagrant/action/general/package_setup_files"

module VagrantPlugins
  module Utm
    module Action
      # This action sets up the files that are used in the package process.
      class PackageSetupFiles < Vagrant::Action::General::PackageSetupFiles
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
