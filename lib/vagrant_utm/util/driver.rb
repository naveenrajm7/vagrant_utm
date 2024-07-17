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
        # TODO: Use VM UUID instead of name
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

        # Execute the 'Open with UTM'
        # @param utm_file [String] The path to the UTM file.
        # @return [void]
        def import(utm_file)
          script_path = @script_path.join("open_with_utm.js")
          cmd = ["osascript", script_path.to_s, utm_file]
          execute(*cmd)
        end

        # Execute the 'start' command to start a machine.
        # @param name [String] The name of the machine.
        # @return [void]
        # TODO: Use VM UUID instead of name
        def start(name)
          cmd = ["utmctl", "start", name]
          execute(*cmd)
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
            raise VagrantPlugins::Utm::Errors::CommandError,
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
