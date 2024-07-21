# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware checks that the VM is accessible, and raises an exception
      # TODO: Define what is inaccessible in UTM and set the state accordingly
      # Currently, UTM does not report inaccessible state,
      # So this plugin will set the state to inaccessible
      # Hence, this action will never raise an exception
      class CheckAccessible
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          if env[:machine].state.id == :inaccessible
            # The VM we are attempting to manipulate is inaccessible. This
            # is a very bad situation and can only be fixed by the user. It
            # also prohibits us from actually doing anything with the virtual
            # machine, so we raise an error.
            raise Vagrant::Errors::VMInaccessible
          end

          @app.call(env)
        end
      end
    end
  end
end
