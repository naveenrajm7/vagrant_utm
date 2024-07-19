# frozen_string_literal: true

require "pathname"
require "vagrant/util/busy"
require "vagrant/util/subprocess"
require_relative "../model/list_result"

module VagrantPlugins
  module Utm
    module Driver
      # Executes commands on the host machine through the AppleScript bridge interface
      # paired with a command line interface.
      class Base
        # Include this so we can use `Subprocess` more easily.
        include Vagrant::Util::Retryable

        def initialize
          # This flag is used to keep track of interrupted state (SIGINT)
          @interrupted = false
          # The path to the scripts directory.
          @script_path = Pathname.new(File.expand_path("../scripts", __dir__))
        end

        # Check if the VM with the given UUID (Name) exists.
        def vm_exists?(uuid); end

        # Returns the current state of this VM.
        #
        # @return [Symbol]
        def read_state; end

        # Execute the 'list' command and returns the list of machines.
        # @return [ListResult] The list of machines.
        def list; end

        # Execute the 'utm://downloadVM?url='
        # See https://docs.getutm.app/advanced/remote-control/
        # @param utm_file_url [String] The url to the UTM file.
        # @return [uuid] The UUID of the imported machine.
        def import(utm_file_url); end

        # Configure the VM with the given config.
        # @param uuid [String] The UUID of the machine.
        # @param config [Config] The configuration of the machine.
        # @return [void]
        def configure(uuid, config); end

        # Execute the 'start' command to start a machine.
        # @param name [String] The name of the machine.
        # @return [void]
        def start(name); end

        # Return UUID of the last VM in the list.
        # @return [uuid] The UUID of the VM.
        def last_uuid; end

        # Halts the virtual machine (pulls the plug).
        def halt; end

        # Suspend the virtual machine.
        def suspend; end

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
