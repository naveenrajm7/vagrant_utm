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

        def call(env)
          customizations = []
          env[:machine].provider_config.customizations.each do |event, command|
            customizations << command if event == @event
          end

          unless customizations.empty?
            env[:ui].info I18n.t("vagrant.actions.vm.customize.running", event: @event)

            # Execute each customization command.
            customizations.each do |command|
              execute_customization(env, command)
            end
          end

          @app.call(env)
        end

        private

        def execute_customization(env, command)
          if command.first == :network_interface
            env[:machine].provider.driver.update_network_interface(command[1], command[2])
          else
            execute_osa_customization(env, command)
          end
        rescue VagrantPlugins::Utm::Errors::CommandError => e
          raise Vagrant::Errors::VMCustomizationFailed, {
            command: command,
            error: e.inspect
          }
        end

        def execute_osa_customization(env, command)
          processed_command = command.map do |arg|
            arg = env[:machine].id if arg == :id
            arg.to_s
          end
          env[:machine].provider.driver.execute_osa_script(processed_command)
        end
      end
    end
  end
end
