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

        # Clears the forwarded ports that have been set on the virtual machine.
        def clear_forwarded_ports; end

        # Checks if the qemu-guest-agent is installed and running in this VM.
        # @return [Boolean]
        def check_qemu_guest_agent; end

        # Forwards a set of ports for a VM.
        #
        # This will not affect any previously set forwarded ports,
        # so be sure to delete those if you need to.
        #
        # The format of each port hash should be the following:
        #
        #     {
        #       name: "foo",
        #       hostport: 8500,
        #       guestport: 80,
        #       adapter: 1,
        #       protocol: "tcp"
        #     }
        #
        # Note that "adapter" and "protocol" are optional and will default
        # to 1 and "tcp" respectively.
        #
        # @param [Array<Hash>] ports An array of ports to set. See documentation
        #   for more information on the format.
        def forward_ports(ports); end

        # Check if the VM with the given UUID (Name) exists.
        def vm_exists?(uuid); end

        # Returns a list of forwarded ports for a VM.
        #
        # @param [String] uuid UUID of the VM to read from, or `nil` if this
        #   VM.

        # @return [Array<Array>] An array of arrays, each of which contains
        # [nic, name(hostport), hostport, guestport]
        def read_forwarded_ports(uuid = nil); end

        # Returns the current state of this VM.
        #
        # @return [Symbol]
        def read_state; end

        # Returns a list of all forwarded ports in use by active
        # virtual machines.
        #
        # @param [Boolean] active_only If true, only VMs that are running will
        #   be checked.
        # @return [Array]
        def read_used_ports(active_only: true); end

        # Returns the IP address of the guest machine.
        #
        # @return [String] The IP address of the guest machine.
        def read_guest_ip; end

        # Returns a list of network interfaces of the VM.
        #
        # @return [Hash]
        def read_network_interfaces; end

        # Execute the 'list' command and returns the list of machines.
        # @return [ListResult] The list of machines.
        def list; end

        # Execute the 'utm://downloadVM?url='
        # See https://docs.getutm.app/advanced/remote-control/
        # @param utm_file_url [String] The url to the UTM file.
        # @return [uuid] The UUID of the imported machine.
        def import(utm_file_url); end

        # Sets the name of the virtual machine.
        # @param name [String] The new name of the machine.
        # @return [void]
        def set_name(name); end # rubocop:disable Naming/AccessorMethodName

        # Reads the SSH port of this VM.
        #
        # @param [Integer] expected Expected guest port of SSH.
        def ssh_port(expected); end

        # Starts the virtual machine referenced by this driver.
        # @return [void]
        def start; end

        # Starts the virtual machine in disposable mode.
        # @return [void]
        def start_disposable; end

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

        # Execute a script using the OSA interface.
        def execute_osa_script(command); end

        # Execute a shell command and return the output.
        def execute_shell(*command, &block) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
          # Get the options hash if it exists
          opts = {}
          opts = command.pop if command.last.is_a?(Hash)

          tries = 0
          tries = 3 if opts[:retryable]

          # Variable to store our execution result
          r = nil

          retryable(on: VagrantPlugins::Utm::Errors::CommandError, tries: tries, sleep: 1) do
            # If there is an error with VBoxManage, this gets set to true
            errored = false

            # Execute the command
            r = raw_shell(*command, &block)

            # If the command was a failure, then raise an exception that is
            # nicely handled by Vagrant.
            if r.exit_code != 0
              if @interrupted
                @logger.info("Exit code != 0, but interrupted. Ignoring.")
              else
                errored = true
              end
            end

            if errored
              raise VagrantPlugins::Utm::Errors::CommandError,
                    command: command.inspect,
                    stderr: r.stderr,
                    stdout: r.stdout
            end
          end

          # Return the output, making sure to replace any Windows-style
          # newlines with Unix-style.
          # AppleScript logs are always in stderr, so we return that
          # if there is any output.
          if r.stdout && !r.stdout.empty?
            r.stdout.gsub("\r\n", "\n")
          elsif r.stderr && !r.stderr.empty?
            r.stderr.gsub("\r\n", "\n")
          else
            ""
          end
        end

        # Executes a command and returns the raw result object.
        def raw_shell(*command, &block)
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
            Vagrant::Util::Subprocess.execute(*command, &block)
          end
        rescue Vagrant::Util::Subprocess::LaunchError => e
          raise Vagrant::Errors::UtmLaunchError,
                message: e.to_s
        end

        # Execute the given subcommand for utmctl and return the output.
        # Copied from https://github.com/hashicorp/vagrant/blob/main/plugins/providers/virtualbox/driver/base.rb.
        # @param [String] subcommand The subcommand to execute.
        # @return [String] The output of the command.
        def execute(*command, &block) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
          # Get the options hash if it exists
          opts = {}
          opts = command.pop if command.last.is_a?(Hash)

          tries = 0
          tries = 3 if opts[:retryable]

          # Variable to store our execution result
          r = nil

          retryable(on: Errors::UtmctlError, tries: tries, sleep: 1) do # rubocop:disable Metrics/BlockLength
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

        # Executes a utmctl command and returns the raw result object.
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
          raise Vagrant::Errors::UtmLaunchError,
                message: e.to_s
        end

        private

        # List of LANG values to attempt to use
        LANG_VARIATIONS = %w[C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8 C POSIX].map(&:freeze).freeze

        # By default set the LANG to C. If the host has the locale command
        # available, check installed locales and verify C is included (or
        # use C variant if available).
        def env_lang # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          # If already set, just return immediately
          return @env_lang if @env_lang

          # Default the LANG to C
          @env_lang = { LANG: "C" }

          # If the locale command is not available, return default
          return @env_lang unless Vagrant::Util::Which.which("locale")

          return @env_lang = @@env_lang if defined?(@@env_lang)

          @logger.debug("validating LANG value for UTM cli commands")
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
            @@env_lang = @env_lang # rubocop:disable Style/ClassVars
          end

          @logger.debug("LANG value set: #{@env_lang[:LANG].inspect}")
          @env_lang
        end
      end
    end
  end
end
