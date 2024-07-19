# frozen_string_literal: true

require "log4r"

require "vagrant/util/platform"

require File.expand_path("base", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 4.5.x
      class Version_4_5 < Base # rubocop:disable Naming/ClassAndModuleCamelCase
        def initialize(uuid)
          super()

          # @logger = Log4r::Logger.new("vagrant::provider::virtualbox_4_3")
          @uuid = uuid
        end

        # Check if the VM with the given UUID (Name) exists.
        def vm_exists?(uuid)
          list_result = list
          list_result.any?(uuid)
        end

        # virtualbox plugin style
        def read_state
          cmd = ["utmctl", "status", @uuid]
          output = execute(*cmd)
          output.strip.to_sym
        end

        def halt
          cmd = ["utmctl", "stop", @uuid]
          execute(*cmd)
        end

        def suspend
          cmd = ["utmctl", "suspend", @uuid]
          execute(*cmd)
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
          puts "Downloading VM from #{utm_file_url}"
          script_path = @script_path.join("downloadVM.sh")
          cmd = [script_path.to_s, utm_file_url]
          execute(*cmd)
          # wait for the VM to be imported
          # TODO: UTM API to give the progress of the import
          # along with the UUID of the imported VM
          sleep(60)
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

        # Return UUID of the last VM in the list.
        # @return [uuid] The UUID of the VM.
        def last_uuid
          list_result = list
          list_result.last.uuid
        end
      end
    end
  end
end
