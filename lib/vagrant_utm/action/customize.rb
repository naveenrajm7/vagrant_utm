# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantPlugins
  module Utm
    module Action
      # This middleware class runs the customizations for the VM.
      class Customize
        def initialize(app, _env, event)
          @app = app
          @event = event
        end

        def call(env) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
          customizations = []
          env[:machine].provider_config.customizations.each do |event, command|
            customizations << command if event == @event
          end

          unless customizations.empty?
            env[:ui].info I18n.t("vagrant.actions.vm.customize.running", event: @event)

            # Execute each customization command.
            customizations.each do |command|
              processed_command = command.collect do |arg|
                arg = env[:machine].id if arg == :id
                arg.to_s
              end

              begin
                env[:machine].provider.driver.execute_osa_script(
                  processed_command
                )
              rescue VagrantPlugins::Utm::Errors::CommandError => e
                raise Vagrant::Errors::VMCustomizationFailed, {
                  command: command,
                  error: e.inspect
                }
              end
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
