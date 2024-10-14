# frozen_string_literal: true

require File.expand_path("version_4_5", __dir__)

module VagrantPlugins
  module Utm
    module Driver
      # Driver for UTM 4.6.x
      class Version_4_6 < Version_4_5 # rubocop:disable Naming/ClassAndModuleCamelCase
        def initialize(uuid)
          super

          @logger = Log4r::Logger.new("vagrant::provider::utm::version_4_6")
        end

        def import(utm)
          utm = Vagrant::Util::Platform.windows_path(utm)

          vm_id = nil

          command = ["import_vm.applescript", utm]
          output = execute_osa_script(command)

          @logger.debug("Import output: #{output}")

          # Check if we got the VM ID
          if output =~ /virtual machine id ([A-F0-9-]+)/
            vm_id = ::Regexp.last_match(1) # Capture the VM ID
          end

          vm_id
        end

        def export(path)
          @logger.debug("Exporting UTM file to: #{path}")
          command = ["export_vm.applescript", @uuid, path]
          execute_osa_script(command)
        end
      end
    end
  end
end
