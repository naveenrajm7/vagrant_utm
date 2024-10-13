# frozen_string_literal: true

require "pathname"
require "vagrant_utm/plugin"

module VagrantPlugins
  # Top level module for the UTM provider plugin.
  module Utm
    lib_path = Pathname.new(File.expand_path("vagrant_utm", __dir__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")

    # Drop some autoloads in here to optimize the performance of loading
    # our drivers only when they are needed.
    module Driver
      lib_path = Pathname.new(File.expand_path("vagrant_utm/driver", __dir__))
      autoload :Meta, lib_path.join("meta")
      autoload :Version_4_5, lib_path.join("version_4_5") # rubocop:disable Naming/VariableNumber
      autoload :Version_4_6, lib_path.join("version_4_6") # rubocop:disable Naming/VariableNumber
    end

    # Drop some autoloads for the model classes
    module Model
      lib_path = Pathname.new(File.expand_path("vagrant_utm/model", __dir__))
      autoload :ForwardedPort, lib_path.join("forwarded_port")
    end

    # Drop some autoloads for the util classes
    module Util
      lib_path = Pathname.new(File.expand_path("vagrant_utm/util", __dir__))
      autoload :CompileForwardedPorts, lib_path.join("compile_forwarded_ports")
    end

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("..", __dir__))
    end
  end
end
