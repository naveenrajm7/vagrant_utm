# frozen_string_literal: true

require "vagrant_utm/config"

RSpec.describe VagrantPlugins::Utm::Config do
  subject(:sut) { described_class.new }

  context "defaults" do
    before { subject.finalize! }

    it { expect(subject.check_guest_additions).to be(true) }
    it { expect(subject.name).to be_nil }
  end

  describe "#network_interface" do
    it "schedules a pre-boot customize with VLAN options" do
      sut.network_interface(
        0,
        vlan_guest_address: "192.168.222.0/24",
        vlan_dhcp_start_address: "192.168.222.2",
        vlan_dhcp_end_address: "192.168.222.254",
        isolate_from_host: false
      )

      event, command = sut.customizations.last
      expect(event).to eq("pre-boot")
      expect(command).to eq([
                              "update_network_interface.applescript",
                              :id,
                              "--index", "0",
                              "--vlan-guest-address", "192.168.222.0/24",
                              "--vlan-dhcp-start-address", "192.168.222.2",
                              "--vlan-dhcp-end-address", "192.168.222.254",
                              "--isolate-from-host", "false"
                            ])
    end

    it "raises when no network options are given" do
      expect do
        sut.network_interface(0)
      end.to raise_error(Vagrant::Errors::ConfigInvalid)
    end
  end

  describe "#validate" do
    it "raises an error if 'utm_file_url' has no value" do
      sut.utm_file_url = nil
      sut.name = "debian"
      sut.finalize!

      result = sut.validate(nil)

      expect(result["UTM Provider"].size).to eq(1)
    end
  end
end
