# frozen_string_literal: true

require "log4r"

require "vagrant/util/platform"

require File.expand_path("base", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 4.5.x
      class Version_4_5 < Base # rubocop:disable Naming/ClassAndModuleCamelCase,Metrics/ClassLength
        def initialize(uuid)
          super()

          @logger = Log4r::Logger.new("vagrant::provider::utm_4_5")
          @uuid = uuid
        end

        def clear_forwarded_ports
          args = []
          read_forwarded_ports(@uuid).each do |nic, name, _, _|
            args.concat(["--index", nic.to_s, name])
          end

          command = ["clear_port_forwards.applescript", @uuid] + args
          execute_osa_script(command) unless args.empty?
        end

        def check_qemu_guest_agent
          # Check if the qemu-guest-agent is installed and running
          # Ideally do: utmctl exec id --cmd systemctl is-active qemu-guest-agent
          # But this is not returning anything, so we just do any utmctl exec command
          # Here we check if the user is root
          output = execute("exec", @uuid, "--cmd", "whoami")
          # check if output contains 'root'
          output.include?("root")
        end

        def forward_ports(ports) # rubocop:disable Metrics/CyclomaticComplexity
          args = []
          ports.each do |options|
            # Convert to UTM protcol enum
            protocol_code = case options[:protocol]
                            when "tcp"
                              "TcPp"
                            when "udp"
                              "UdPp"
                            else
                              raise Errors::ForwardedPortInvalidProtocol
                            end

            pf_builder = [
              # options[:name], # Name is not supported in UTM
              protocol_code || "TcPp", # Default to TCP
              options[:guestip] || "",
              options[:guestport],
              options[:hostip] || "",
              options[:hostport]
            ]

            args.concat(["--index", options[:adapter].to_s,
                         pf_builder.join(",")])
          end

          command = ["add_port_forwards.applescript", @uuid] + args
          execute_osa_script(command) unless args.empty?
        end

        # Check if the VM with the given UUID  exists.
        def vm_exists?(uuid)
          list_result = list
          list_result.any?(uuid)
        end

        def read_forwarded_ports(uuid = nil, active_only: false) # rubocop:disable Metrics/AbcSize
          uuid ||= @uuid

          @logger.debug("read_forward_ports: uuid=#{uuid} active_only=#{active_only}")

          # If we care about active VMs only, then we check the state
          # to verify the VM is running.
          return [] if active_only && read_state != :started

          # Get the forwarded ports from emulated Network interface
          # Format: [nicIndex, name, hostPort, guestPort]
          # We use hostPort as the name, since UTM does not support name
          # Becuase hostport is and should be unique
          results = []
          command = ["read_forwarded_ports.applescript", @uuid]
          info = execute_osa_script(command)
          info.strip! # remove leading and trailing whitespaces to match the regex
          info.split("\n").each do |line|
            # Parse info, Forwarding(nicIndex)(ruleIndex)="Protocol,GuestIP,GuestPort,HostIP,HostPort"
            next unless (matcher = /^Forwarding\((\d+)\)\((\d+)\)="(.+?),.*?,(.+?),.*?,(.+?)"$/.match(line))

            #        nicIndex         name( our hostPort)   hostport        guestport
            result = [matcher[1].to_i, matcher[5], matcher[5].to_i, matcher[4].to_i]
            @logger.debug("  - #{result.inspect}")
            results << result
          end

          results
        end

        def read_guest_ip
          command = ["read_guest_ip.applescript", @uuid]
          output = execute_osa_script(command)
          output.strip
        end

        def read_network_interfaces
          nics = {}
          command = ["read_network_interfaces.applescript", @uuid]
          info = execute_osa_script(command)
          info.strip! # remove leading and trailing whitespaces to match the regex
          info.split("\n").each do |line|
            next unless (matcher = /^nic(\d+),(.+?)$/.match(line))

            adapter = matcher[1].to_i
            type = matcher[2].to_sym
            nics[adapter] ||= {}
            nics[adapter][:type] = type
          end

          nics
        end

        # virtualbox plugin style
        def read_state
          output = execute("status", @uuid)
          output.strip.to_sym
        end

        def set_name(name) # rubocop:disable Naming/AccessorMethodName
          command = ["customize_vm.applescript", @uuid, "--name", name.to_s]
          execute_osa_script(command)
        end

        def delete
          execute("delete", @uuid)
        end

        def start
          execute("start", @uuid)
        end

        def start_disposable
          execute("start", @uuid, "--disposable")
        end

        def halt
          execute("stop", @uuid)
        end

        def suspend
          execute("suspend", @uuid)
        end

        def execute_shell_command(command)
          execute_shell(*command)
        end

        def execute_osa_script(command)
          script_path = @script_path.join(command[0])
          cmd = ["osascript", script_path.to_s] + command[1..]
          execute_shell(*cmd)
        end

        # Execute the 'list' command and returns the list of machines.
        # @return [ListResult] The list of machines.
        def list
          script_path = @script_path.join("list_vm.js")
          cmd = ["osascript", script_path.to_s]
          result = execute_shell(*cmd)
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
          execute_shell(*cmd)
          # wait for the VM to be imported
          # TODO: UTM API to give the progress of the import
          # along with the UUID of the imported VM
          # sleep(60)
          # Get the UUID of the imported VM
          # HACK: Currently we do not know the UUID of the imported VM
          # So, we just get the UUID of the last VM in the list
          # which is the last imported VM (unless UTM changes the order)
          # TODO: Use UTM API to get the UUID of the imported VM
          # last_uuid
        end

        # Return UUID of the last VM in the list.
        # @return [uuid] The UUID of the VM.
        def last_uuid
          list_result = list
          list_result.last.uuid
        end

        def verify!
          # Verify proper functionality of UTM
          # add any command that should be checked
          # we now only check if the 'utmctl' command is available
          execute("--list")
        end
      end
    end
  end
end
