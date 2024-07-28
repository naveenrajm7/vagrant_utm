# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action checks if qemu-img is installed.
      class CheckQemuImg
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          qemu_img_present = Vagrant::Util::Which.which("qemu-img")
          raise Errors::QemuImgRequired unless qemu_img_present

          @app.call(env)
        end
      end
    end
  end
end
