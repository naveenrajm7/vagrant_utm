# frozen_string_literal: true

require_relative "../base"

RSpec.describe VagrantPlugins::Utm::Driver::Version_5_0 do
  include_context "utm"
  let(:utm_version) { "5.0.4" }
  subject { VagrantPlugins::Utm::Driver::Meta.new(uuid) }

  it_behaves_like "a version 4.x utm driver"

  describe "#update_network_interface" do
    it "runs update_network_interface.applescript with VLAN options" do
      expect(subprocess).to receive(:execute)
        .with(
          "osascript",
          File.join(script_path, "update_network_interface.applescript"),
          uuid,
          "--index", "0",
          "--vlan-guest-address", "192.168.222.0/24",
          "--vlan-dhcp-start-address", "192.168.222.2",
          "--vlan-dhcp-end-address", "192.168.222.254",
          "--isolate-from-host", "false",
          an_instance_of(Hash)
        )
        .and_return(subprocess_result)

      subject.update_network_interface(
        0,
        vlan_guest_address: "192.168.222.0/24",
        vlan_dhcp_start_address: "192.168.222.2",
        vlan_dhcp_end_address: "192.168.222.254",
        isolate_from_host: false
      )
    end

    it "raises when UTM is older than 5.0.4" do
      allow(subprocess).to receive(:execute)
        .with("osascript", "-e",
              'tell application "System Events" to return version of application "UTM"',
              an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "5.0.3"))

      driver = VagrantPlugins::Utm::Driver::Version_5_0.new(uuid)
      expect do
        driver.update_network_interface(0, vlan_guest_address: "192.168.222.0/24")
      end.to raise_error(VagrantPlugins::Utm::Errors::UtmInvalidVersion)
    end
  end
end
