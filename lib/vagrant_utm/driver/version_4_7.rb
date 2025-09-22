# frozen_string_literal: true

require File.expand_path("version_4_6", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 4.7.x
      class Version_4_7 < Version_4_6 # rubocop:disable Naming/ClassAndModuleCamelCase
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_4_7")
        end
      end
    end
  end
end
