# frozen_string_literal: true

require File.expand_path("version_4_7", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 5.0.x
      class Version_5_0 < Version_4_7 # rubocop:disable Naming/ClassAndModuleCamelCase
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_5_0")
        end
      end
    end
  end
end
