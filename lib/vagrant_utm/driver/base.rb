# frozen_string_literal: true

require "log4r"
require "pathname"
require "vagrant/util/busy"
require "vagrant/util/subprocess"
require "vagrant/util/which"
require_relative "../model/list_result"

module VagrantPlugins
  module Utm
    module Driver
      # Executes commands on the host machine through the AppleScript bridge interface
      # paired with a command line interface.
      class Base # rubocop:disable Metrics/ClassLength
        # Include this so we can use `Subprocess` more easily.
        include Vagrant::Util::Retryable

        def initialize
          @logger = Log4r::Logger.new("vagrant::provider::utm::base")

          # This flag is used to keep track of interrupted state (SIGINT)
          @interrupted = false
          # The path to the scripts directory.
          @script_path = Pathname.new(File.expand_path("../scripts", __dir__))

          # Set 'utmctl' path
          @utmctl_path = Vagrant::Util::Which.which("utmctl")

          # if not found, fall back to /usr/local/bin/utmctl
          @utmctl_path ||= "/Applications/UTM.app/Contents/MacOS/utmctl"
          @logger.info("utmctl path: #{@utmctl_path}")
        end

        # Checks if the qemu-guest-agent is installed and running in this VM.
        # @return [Boolean]
        def check_qemu_guest_agent; end

        # Check if the VM with the given UUID (Name) exists.
        def vm_exists?(uuid); end

        # Returns the current state of this VM.
        #
        # @return [Symbol]
        def read_state; end

        # Returns the IP address of the guest machine.
        #
        # @return [String] The IP address of the guest machine.
        def read_guest_ip; end

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

        # Starts the virtual machine referenced by this driver.
        # @return [void]
        def start; end

        # Deletes the virtual machine references by this driver.
        # @return [void]
        def delete; end

        # Return UUID of the last VM in the list.
        # @return [uuid] The UUID of the VM.
        def last_uuid; end

        # Halts the virtual machine (pulls the plug).
        def halt; end

        # Suspend the virtual machine.
        def suspend; end

        # Verifies that the driver is ready to accept work.
        #
        # This should raise a VagrantError if things are not ready.
        def verify!; end

        # Execute a raw shell command
        #
        # Raises a CommandError if the command fails.
        # @param [Array] command The command to execute.
        def execute_shell_command(command); end

        # Execute a script using the OSA interface.
        def execute_osa_script(command); end

        # Execute a command on the host machine.
        # Heavily inspired from https://github.com/hashicorp/vagrant/blob/main/plugins/providers/docker/executor/local.rb.
        def execute_shell(*cmd, &block)
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

        # Execute the given subcommand for utmctl and return the output.
        # Copied from https://github.com/hashicorp/vagrant/blob/main/plugins/providers/virtualbox/driver/base.rb.
        # @param [String] subcommand The subcommand to execute.
        # @return [String] The output of the command.
        def execute(*command, &block)
          # Get the options hash if it exists
          opts = {}
          opts = command.pop if command.last.is_a?(Hash)

          tries = 0
          tries = 3 if opts[:retryable]

          # Variable to store our execution result
          r = nil

          retryable(on: Errors::UtmctlError, tries: tries, sleep: 1) do
            # if there is an error with utmctl, this gets set to true
            errored = false

            # Execute the command
            r = raw(*command, &block)

            # If the command was a failure, then raise an exception that is
            # nicely handled by Vagrant.
            if r.exit_code != 0
              if @interrupted
                @logger.info("Exit code != 0, but interrupted. Ignoring.")
              elsif r.exit_code == 126
                # To be consistent with VBoxManage
                raise Errors::UtmctlNotFoundError
              else
                errored = true
              end
            else
              # if utmctl fails but doesn't exit with an error code
              # Handle those cases here

              if r.stderr =~ /Error/
                @logger.info("Error found, assuming error.")
                errored = true
              end

              if r.stderr =~ /OSStatus error/
                @logger.info("OSStatus error found, assuming error.")
                errored = true

              end
            end

            # If there was an error running utmctl, show the error and the output
            if errored
              raise Errors::UtmctlError,
                    command: command.inspect,
                    stderr: r.stderr,
                    stdout: r.stdout
            end
          end

          # Return the output, making sure to replace any Windows-style
          # newlines with Unix-style.
          r.stdout.gsub("\r\n", "\n")
        end

        # Executes a command and returns the raw result object.
        def raw(*command, &block)
          int_callback = lambda do
            @interrupted = true

            # We have to execute this in a thread due to trap contexts
            # and locks.
            Thread.new { @logger.info("Interrupted.") }.join
          end

          # Append in the options for subprocess
          # NOTE: We include the LANG env var set to C to prevent command output
          #       from being localized
          command << { notify: %i[stdout stderr], env: env_lang }

          Vagrant::Util::Busy.busy(int_callback) do
            Vagrant::Util::Subprocess.execute(@utmctl_path, *command, &block)
          end
        rescue Vagrant::Util::Subprocess::LaunchError => e
          raise Vagrant::Errors::UtmctlLaunchError,
                message: e.to_s
        end

        private

        # List of LANG values to attempt to use
        LANG_VARIATIONS = %w[C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8 C POSIX].map(&:freeze).freeze

        # By default set the LANG to C. If the host has the locale command
        # available, check installed locales and verify C is included (or
        # use C variant if available).
        def env_lang
          # If already set, just return immediately
          return @env_lang if @env_lang

          # Default the LANG to C
          @env_lang = { LANG: "C" }

          # If the locale command is not available, return default
          return @env_lang unless Vagrant::Util::Which.which("locale")

          return @env_lang = @@env_lang if defined?(@@env_lang)

          @logger.debug("validating LANG value for virtualbox cli commands")
          # Get list of available locales on the system
          result = Vagrant::Util::Subprocess.execute("locale", "-a")

          # If the command results in an error, just log the error
          # and return the default value
          if result.exit_code != 0
            @logger.warn("locale command failed (exit code: #{result.exit_code}): #{result.stderr}")
            return @env_lang
          end
          available = result.stdout.lines.map(&:chomp).find_all do |l|
            l == "C" || l == "POSIX" || l.start_with?("C.") || l.start_with?("en_US.")
          end
          @logger.debug("list of available C locales: #{available.inspect}")

          # Attempt to find a valid LANG from locale list
          lang = LANG_VARIATIONS.detect { |l| available.include?(l) }

          if lang
            @logger.debug("valid variation found for LANG value: #{lang}")
            @env_lang[:LANG] = lang
            @@env_lang = @env_lang
          end

          @logger.debug("LANG value set: #{@env_lang[:LANG].inspect}")
          @env_lang
        end
      end
    end
  end
end
