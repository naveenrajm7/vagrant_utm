# frozen_string_literal: true

require "pathname"
require "vagrant_utm/plugin"

module VagrantPlugins
  # Top level module for the UTM provider plugin.
  module Utm
    lib_path = Pathname.new(File.expand_path("vagrant_utm", __dir__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")
    # autoload :Driver, lib_path.join("driver/base")

    # Drop some autoloads in here to optimize the performance of loading
    # our drivers only when they are needed.
    module Driver
      lib_path = Pathname.new(File.expand_path("vagrant_utm/driver", __dir__))
      autoload :Meta, lib_path.join("meta")
      autoload :Version_4_5, lib_path.join("version_4_5") # rubocop:disable Naming/VariableNumber
    end

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("..", __dir__))
    end
  end
end
