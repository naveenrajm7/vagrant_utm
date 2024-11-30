# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

require "vagrant/util/template_renderer"

module VagrantPlugins
  module Utm
    module Action
      # This middleware class sets up the Vagrantfile that will be placed
      # into the root of the exported box.
      class PackageVagrantfile
        # For TemplateRenderer
        include Vagrant::Util

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          @env = env
          create_vagrantfile
          @app.call(env)
        end

        # This method creates the auto-generated Vagrantfile at the root of the
        # box. This Vagrantfile can contain anything that might be essential for user.
        # Ex: Mac Address (for VirtualBox), etc.
        # Currently nothing is added to the Vagrantfile.
        def create_vagrantfile
          File.open(File.join(@env["export.temp_dir"], "Vagrantfile"), "w") do |f|
            f.write(TemplateRenderer.render("package_Vagrantfile"))
          end
        end
      end
    end
  end
end
