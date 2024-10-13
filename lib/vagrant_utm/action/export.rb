# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action destroys the running machine.
      class Export
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          @env = env

          raise Vagrant::Errors::VMPowerOffToPackage if \
            @env[:machine].state.id != :stopped

          export

          @app.call(env)
        end

        def export
          @env[:ui].info I18n.t("vagrant.actions.vm.export.exporting")
          @env[:machine].provider.driver.export(utm_path) do |progress|
            @env[:ui].rewriting do |ui|
              ui.clear_line
              ui.report_progress(progress.percent, 100, false)
            end
          end

          # Clear the line a final time so the next data can appear
          # alone on the line.
          @env[:ui].clear_line
        end

        def utm_path
          File.join(@env["export.temp_dir"], "box.utm")
        end
      end
    end
  end
end
