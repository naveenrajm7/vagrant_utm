# frozen_string_literal: true

RSpec.describe VagrantPlugins::Utm::Action::HandleForwardedPortCollisions do # rubocop:disable Metrics/BlockLength
  include_context "unit"

  let(:app) { double("app", call: nil) }
  let(:options) { { guest: 22, host: 2222, host_ip: "127.0.0.1", auto_correct: true } }
  let(:networks) { [[:forwarded_port, options]] }
  let(:vm_config) { double("vm_config", networks: networks, usable_port_range: 2200..2250) }
  let(:data_dir) { temporary_dir }
  let(:machine_env) { double("machine_env", data_dir: data_dir) }
  let(:machine) { double("machine", name: "parrot", env: machine_env, config: double(vm: vm_config)) }
  let(:env) { { machine: machine, ui: double(info: nil), port_collision_repair: true } }
  subject(:middleware) { described_class.new(app, env) }

  before do
    allow(machine_env).to receive(:lock).with("fpcollision").and_yield
  end

  it "rejects an exhausted range instead of forwarding the last occupied port" do
    env[:port_collision_port_check] = ->(_ip, _port) { true }

    expect { middleware.call(env) }.to raise_error(Vagrant::Errors::ForwardPortAutolistEmpty)
    expect(options[:host]).to eq(2222)
    expect(app).not_to have_received(:call)
  end

  it "uses a bindable port even if TCP connection probes report every port open" do
    allow(Socket).to receive(:tcp).and_return(double(close: nil))
    allow(TCPServer).to receive(:new).and_return(double(close: nil))
    env[:port_collision_extra_in_use] = [2222, 2250]

    middleware.call(env)

    expect(options[:host]).to eq(2200)
    expect(app).to have_received(:call).with(env)
  end

  it "skips occupied and leased candidates" do
    env[:port_collision_extra_in_use] = [2222, 2200]
    env[:port_collision_port_check] = ->(_ip, port) { port == 2201 }
    data_dir.join("fp-leases").mkpath
    data_dir.join("fp-leases", "127_0_0_1_2202").write(Time.now.to_i.to_s)

    middleware.call(env)

    expect(options[:host]).to eq(2203)
    expect(data_dir.join("fp-leases").children.map { |path| path.basename.to_s }).to eq(["127_0_0_1_2202"])
  end

  it "raises a collision when automatic correction is disabled" do
    options[:auto_correct] = false
    env[:port_collision_extra_in_use] = [2222]

    expect { middleware.call(env) }.to raise_error(Vagrant::Errors::ForwardPortCollision)
  end

  it "does not give two rules the same repaired port" do
    networks << [:forwarded_port, options.merge(guest: 80, host: 8080)]
    env[:port_collision_port_check] = ->(_ip, port) { [2222, 8080].include?(port) }

    middleware.call(env)

    expect(networks.map { |_, rule| rule[:host] }).to eq([2200, 2201])
  end

  describe "bind checks" do
    it "closes the probe socket and leaves a free port unchanged" do
      socket = double("socket")
      expect(TCPServer).to receive(:new).with("127.0.0.1", 2222).and_return(socket)
      expect(socket).to receive(:close)

      middleware.call(env)

      expect(options[:host]).to eq(2222)
    end

    it "checks unspecified host addresses on all interfaces" do
      options.delete(:host_ip)
      expect(TCPServer).to receive(:new).with("0.0.0.0", 2222).and_return(double(close: nil))

      middleware.call(env)
    end

    it "repairs a port that cannot be bound" do
      allow(TCPServer).to receive(:new).with("127.0.0.1", 2222).and_raise(Errno::EADDRINUSE)
      allow(TCPServer).to receive(:new).with("127.0.0.1", 2200).and_return(double(close: nil))

      middleware.call(env)

      expect(options[:host]).to eq(2200)
    end
  end
end
