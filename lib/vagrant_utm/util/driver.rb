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

        # Execute the 'utm://downloadVM?url='
        # See https://docs.getutm.app/advanced/remote-control/
        # @param utm_file_url [String] The url to the UTM file.
        # @return [uuid] The UUID of the imported machine.
        def import(utm_file_url)
          script_path = @script_path.join("downloadVM.sh")
          cmd = [script_path.to_s, utm_file_url]
          execute(*cmd)
          # wait for the VM to be imported
          # TODO: UTM API to give the progress of the import
          # along with the UUID of the imported VM
          sleep(30)
          # Get the UUID of the imported VM
          # HACK: Currently we do not know the UUID of the imported VM
          # So, we just get the UUID of the last VM in the list
          # which is the last imported VM (unless UTM changes the order)
          # TODO: Use UTM API to get the UUID of the imported VM
          last_uuid
        end

        # Configure the VM with the given config.
        # @param uuid [String] The UUID of the machine.
        # @param config [Config] The configuration of the machine.
        # @return [void]
        def configure(uuid, config)
          script_path = @script_path.join("configure_vm.applescript")
          cmd = ["osascript", script_path.to_s, uuid, config.name]
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

        private

        # Return UUID of the last VM in the list.
        # @return [uuid] The UUID of the VM.
        def last_uuid
          list_result = list
          list_result.last.uuid
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
