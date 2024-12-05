# frozen_string_literal: true

module VagrantPlugins
  module Utm
    module Action
      # This action prepares the NFS settings for the machine.
      class PrepareNFSSettings
        include Vagrant::Action::Builtin::MixinSyncedFolders
        include Vagrant::Util::Retryable

        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::action::vm::nfs")
        end

        def call(env)
          @machine = env[:machine]

          @app.call(env)

          opts = {
            cached: !env[:synced_folders_cached].nil?,
            config: env[:synced_folders_config],
            disable_usable_check: !env[:test].nil?
          }
          folders = synced_folders(env[:machine], **opts)

          return unless folders.key?(:nfs)

          @logger.info("Using NFS, preparing NFS settings by reading host IP and machine IP")
          add_ips_to_env!(env)
        end

        # Extracts the proper host and guest IPs for NFS mounts and stores them
        # in the environment for the SyncedFolder action to use them in
        # mounting.
        #
        # The ! indicates that this method modifies its argument.
        def add_ips_to_env!(env)
          # Hardcoded IP for the host IP
          host_ip = "10.0.2.2"
          machine_ip = read_dynamic_machine_ip

          raise Vagrant::Errors::NFSNoHostonlyNetwork if !host_ip || !machine_ip

          env[:nfs_host_ip]    = host_ip
          env[:nfs_machine_ip] = machine_ip
        end

        # Returns the IP address of the guest by looking at utm guest additions
        # for the appropriate guest adapter.
        #
        # For DHCP interfaces, the guest property will not be present until the
        # guest completes
        #
        # @param [Integer] adapter number to read IP for
        # @return [String] ip address of adapter
        def read_dynamic_machine_ip
          # we need to wait for the guest's IP to show up as a guest property.
          # retry thresholds are relatively high since we might need to wait
          # for DHCP, but even static IPs can take a second or two to appear.
          retryable(retry_options.merge(on: Vagrant::Errors::VirtualBoxGuestPropertyNotFound)) do
            # Read the IP address from the list given by qemu-guest-agent
            @machine.provider.driver.read_guest_ip[0]
          end
        rescue Vagrant::Errors::VirtualBoxGuestPropertyNotFound
          # this error is more specific with a better error message directing
          # the user towards the fact that it's probably a reportable bug
          raise Vagrant::Errors::NFSNoGuestIP
        end

        # Separating these out so we can stub out the sleep in tests
        def retry_options
          { tries: 15, sleep: 1 }
        end
      end
    end
  end
end
