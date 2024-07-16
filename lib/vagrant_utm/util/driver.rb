# frozen_string_literal: true

require "pathname"
require "vagrant/util/busy"
require "vagrant/util/subprocess"
require_relative "../model/list_result"

module VagrantPlugins
  module Utm
    module Util
      # Executes commands on the host machine through the AppleScript bridge interface
      # paired with a command line interface.
      class Driver
        # Initializes the driver with the path to the scripts directory.
        def initialize
          @script_path = Pathname.new(File.expand_path("../scripts", __dir__))
        end

        # Execute the 'status' command and returns the machine status.
        # @param name [String] The name of the machine.
        # @return status [String] The status of the machine.
        def get_status(name)
          cmd = ["utmctl", "status", name]
          result = execute(*cmd)
          result.strip
        end

        # Execute the 'list' command and returns the list of machines.
        # @return [ListResult] The list of machines.
        def list
          script_path = @script_path.join("list_vm.js")
          cmd = ["osascript", script_path.to_s]
          result = execute(*cmd)
          data = JSON.parse(result)
          Model::ListResult.new(data)
        end

        # Execute a command on the host machine.
        # Heavily inspired from https://github.com/hashicorp/vagrant/blob/main/plugins/providers/docker/executor/local.rb.
        def execute(*cmd, &block)
          # Append in the options for subprocess
          cmd << { notify: %i[stdout stderr] }

          interrupted  = false
          int_callback = -> { interrupted = true }
          result = ::Vagrant::Util::Busy.busy(int_callback) do
            ::Vagrant::Util::Subprocess.execute(*cmd, &block)
          end

          # Trim the outputs
          result.stderr.gsub!("\r\n", "\n")
          result.stdout.gsub!("\r\n", "\n")

          if result.exit_code != 0 && !interrupted
            raise VagrantPlugins::Tart::Errors::CommandError,
                  command: cmd.inspect,
                  stderr: result.stderr,
                  stdout: result.stdout
          end

          # Return the outputs of the command
          "#{result.stdout} #{result.stderr}"
        end
      end
    end
  end
end
