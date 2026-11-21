# frozen_string_literal: true

require "vagrant/action/builtin/handle_forwarded_port_collisions"

module VagrantPlugins
  module Utm
    module Action
      # Keep Vagrant's lock and leases, but test whether QEMU can bind a port.
      class HandleForwardedPortCollisions < Vagrant::Action::Builtin::HandleForwardedPortCollisions
        protected

        def handle(env) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          extra = env[:port_collision_extra_in_use] || []
          extra = extra.to_h { |port| [port, Set.new(["*"])] } if extra.is_a?(Array)
          remap = env[:port_collision_remap] || {}
          checker = env[:port_collision_port_check] || method(:port_check)
          usable = Set.new(@machine.config.vm.usable_port_range) - extra.keys
          with_forwarded_ports(env) { |options| usable.delete(options[:host]) }

          with_forwarded_ports(env) do |options|
            next if options[:disabled] || (options[:protocol] && options[:protocol] != "tcp")

            host = remap.fetch(options[:host], options[:host])
            ip = options[:host_ip]
            next unless port_in_use?(extra, checker, ip, host)

            unless env[:port_collision_repair] && options[:auto_correct]
              raise Vagrant::Errors::ForwardPortCollision,
                    guest_port: options[:guest].to_s, host_port: host.to_s
            end

            repaired = usable.to_a.sort.find do |port|
              usable.delete(port)
              !port_in_use?(extra, checker, ip, port)
            end
            unless repaired
              raise Vagrant::Errors::ForwardPortAutolistEmpty,
                    vm_name: @machine.name, guest_port: options[:guest].to_s, host_port: host.to_s
            end

            options[:host] = repaired
            env[:ui].info(I18n.t("vagrant.actions.vm.forward_ports.fixed_collision",
                                 host_port: host.to_s, guest_port: options[:guest].to_s,
                                 new_port: repaired.to_s))
          end
        end

        def port_in_use?(extra, checker, ip, port)
          # An array from read_used_ports represents reservations on any IP.
          extra.fetch(port, []).include?("*") || is_forwarded_already(extra, port, ip) ||
            call_port_checker(checker, ip, port) || lease_check(ip, port)
        end

        def port_check(host_ip, host_port)
          # A successful connect can be misleading (for example with local
          # traffic proxies). Binding checks the operation QEMU needs instead.
          socket = TCPServer.new(host_ip.nil? || host_ip.empty? ? "0.0.0.0" : host_ip, host_port)
          false
        rescue Errno::EADDRINUSE, Errno::EACCES, Errno::EADDRNOTAVAIL
          true
        ensure
          socket&.close
        end
      end
    end
  end
end
