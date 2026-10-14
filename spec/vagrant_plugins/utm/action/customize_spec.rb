# frozen_string_literal: true

RSpec.describe VagrantPlugins::Utm::Action::Customize do
  let(:options) { { vlan_guest_address: "192.168.222.0/24" } }
  let(:driver) { double("driver") }
  let(:machine) do
    double("machine",
           provider_config: double(customizations: [["pre-boot", [:network_interface, 0, options]]]),
           provider: double(driver: driver))
  end
  let(:app) { double("app") }
  let(:env) { { machine: machine, ui: double(info: nil) } }

  it "applies network settings through the version-checked driver" do
    expect(driver).to receive(:update_network_interface).with(0, options)
    expect(app).to receive(:call).with(env)

    described_class.new(app, {}, "pre-boot").call(env)
  end
end
