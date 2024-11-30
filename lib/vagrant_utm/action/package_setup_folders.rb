# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "fileutils"

require "vagrant/action/general/package_setup_folders"

module VagrantPlugins
  module Utm
    module Action
      # This action sets up the folders that are used in the package process.
      class PackageSetupFolders < Vagrant::Action::General::PackageSetupFolders
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
