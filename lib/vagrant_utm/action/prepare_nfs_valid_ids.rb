# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This action prepares the NFS valid IDs for the VMs.
      # The ids that are valid and should not be pruned by NFS
      class PrepareNFSValidIds
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::action::vm::nfs")
        end

        def call(env)
          env[:nfs_valid_ids] = env[:machine].provider.driver.read_vms.keys
          @app.call(env)
        end
      end
    end
  end
end
