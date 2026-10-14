# frozen_string_literal: true

require_relative "../base"

RSpec.describe VagrantPlugins::Utm::Driver::Version_5_0 do # rubocop:disable Metrics/BlockLength
  include_context "utm"
  let(:utm_version) { "5.0.6" }
  let(:snapshot_api_version) { "5.0.6" }
  subject { VagrantPlugins::Utm::Driver::Meta.new(uuid) }

  it_behaves_like "a version 4.x utm driver"

  describe "#update_network_interface" do # rubocop:disable Metrics/BlockLength
    before do
      allow(subprocess).to receive(:execute)
        .with(utmctl_path, "version", an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "5.0.6\n"))
    end

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
        .with(utmctl_path, "version", an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "5.0.3\n"))

      driver = VagrantPlugins::Utm::Driver::Version_5_0.new(uuid)
      expect do
        driver.update_network_interface(0, vlan_guest_address: "192.168.222.0/24")
      end.to raise_error(VagrantPlugins::Utm::Errors::UtmInvalidVersion)
    end
  end

  describe "snapshots" do # rubocop:disable Metrics/BlockLength
    before do
      allow(subprocess).to receive(:execute)
        .with(utmctl_path, "version", an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "#{snapshot_api_version}\n"))
    end

    it "creates a snapshot through utmctl" do
      expect(subprocess).to receive(:execute)
        .with(utmctl_path, "snapshot", "create", uuid, "--name", "baseline",
              an_instance_of(Hash))
        .and_return(subprocess_result)

      subject.create_snapshot(uuid, "baseline")
    end

    it "deletes a snapshot through utmctl" do
      expect(subprocess).to receive(:execute)
        .with(utmctl_path, "snapshot", "delete", uuid, "--snapshot", "baseline",
              an_instance_of(Hash))
        .and_return(subprocess_result)

      subject.delete_snapshot(uuid, "baseline")
    end

    it "lists snapshots from utmctl JSON output" do
      expect(subprocess).to receive(:execute)
        .with(utmctl_path, "snapshot", "list", uuid, "--json",
              an_instance_of(Hash))
        .and_return(subprocess_result(stdout: '[{"id":"s1","name":"newest"},' \
                                              '{"id":"s2","name":"release-1.0"}]'))

      expect(subject.list_snapshots(uuid)).to eq(["newest", "release-1.0"])
    end

    it "restores a snapshot through utmctl" do
      expect(subprocess).to receive(:execute)
        .with(utmctl_path, "snapshot", "restore", uuid, "--snapshot", "baseline",
              an_instance_of(Hash))
        .and_return(subprocess_result)

      subject.restore_snapshot(uuid, "baseline")
    end

    it "requires UTM 5.0.6 or newer" do
      allow(subprocess).to receive(:execute)
        .with(utmctl_path, "version", an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "5.0.5\n"))

      expect { subject.list_snapshots(uuid) }
        .to raise_error(VagrantPlugins::Utm::Errors::UtmInvalidVersion)
    end
  end
end
