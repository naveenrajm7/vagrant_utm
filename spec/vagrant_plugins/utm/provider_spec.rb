# frozen_string_literal: true

require "vagrant_utm/provider"

RSpec.describe VagrantPlugins::Utm::Provider do # rubocop:disable Metrics/BlockLength
  let(:driver) { double("driver") }
  let(:provider) { double("provider", driver: driver) }
  let(:provider_config) { double("provider_config") }
  let(:uid) { "1000" }
  let(:machine) { double("machine", uid: uid, provider: provider, provider_config: provider_config) }

  let(:platform) { double("platform") }

  subject { described_class.new(machine) }

  before do
    stub_const("Vagrant::Util::Platform", platform)
    allow(platform).to receive(:windows?).and_return(false)
    allow(platform).to receive(:cygwin?).and_return(false)
    allow(platform).to receive(:darwin?).and_return(true)
    allow(platform).to receive(:wsl?).and_return(false)
    allow(platform).to receive(:wsl_windows_access_bypass?).and_return(false)
    allow(machine).to receive(:id).and_return("foo")

    allow(Process).to receive(:uid).and_return(uid)
  end

  describe ".usable?" do
    subject { described_class }

    it "returns true if usable" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new).and_return(driver)
      expect(subject).to be_usable
    end

    it "raises an execption if UTM is not available" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new)
        .and_raise(VagrantPlugins::Utm::Errors::UtmNotDetected)

      expect { subject.usable?(true) }
        .to raise_error(VagrantPlugins::Utm::Errors::UtmNotDetected)
    end

    it "raises an execption if UTM version is invalid" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new)
        .and_raise(VagrantPlugins::Utm::Errors::UtmInvalidVersion, supported_versions: "1,2,3")

      expect { subject.usable?(true) }
        .to raise_error(VagrantPlugins::Utm::Errors::UtmInvalidVersion)
    end

    it "raises an execption if utmctl is not found" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new)
        .and_raise(VagrantPlugins::Utm::Errors::UtmctlNotFoundError)

      expect { subject.usable?(true) }
        .to raise_error(VagrantPlugins::Utm::Errors::UtmctlNotFoundError)
    end
  end

  describe "#driver" do
    it "is initialized" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new).and_return(driver)
      expect(subject.driver).to be(driver)
    end
  end

  describe "#state" do
    it "returns not_created if no ID" do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new).and_return(driver)
      allow(driver).to receive(:uuid).and_return(nil)

      expect(subject.state.id).to eq(:not_created)
    end
  end

  describe "#ssh_info" do
    let(:result) { "127.0.0.1" }
    let(:exit_code) { 0 }
    let(:ssh_info) { { host: result, port: 22 } }
    let(:ssh) { double("ssh", guest_port: 22) }
    let(:config) { double("config", ssh: ssh) }

    before do
      allow(VagrantPlugins::Utm::Driver::Meta).to receive(:new).and_return(driver)
      allow(machine).to receive(:action).with(:read_state).and_return(machine_state_id: :started)
      allow(machine).to receive(:data_dir).and_return(".vagrant")
      allow(driver).to receive(:uuid).and_return("1234")
      allow(driver).to receive(:read_state).and_return(:started)
      allow(driver).to receive(:ssh_port).and_return(22)
      allow(machine).to receive(:config).and_return(config)
    end

    it "returns nil if machine state is not started" do
      allow(driver).to receive(:read_state).and_return(:not_created)
      expect(subject.ssh_info).to eq(nil)
    end

    it "should receive a valid address" do
      allow(driver).to receive(:execute).with(:get_network_config).and_return(result)

      allow(driver).to receive(:read_guest_ip).and_return({ "ip" => "127.0.0.1" })
      expect(subject.ssh_info).to eq(ssh_info)
    end
  end
end
