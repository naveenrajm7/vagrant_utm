# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "vagrant/util/platform"

module VagrantPlugins
  module Utm
    module Action
      # Checks that UTM is installed and ready to be used.
      class CheckUtm
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::provider::utm")
        end

        def call(env)
          # This verifies that UTM is installed and the driver is
          # ready to function. If not, then an exception will be raised
          # which will break us out of execution of the middleware sequence.
          Driver::Meta.new.verify!

          # Carry on.
          @app.call(env)
        end
      end
    end
  end
end
