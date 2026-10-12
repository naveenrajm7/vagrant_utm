# frozen_string_literal: true

require_relative "../base"

RSpec.describe VagrantPlugins::Utm::Driver::Version_5_0 do # rubocop:disable Metrics/BlockLength
  include_context "utm"
  let(:utm_version) { "5.0.6" }
  let(:snapshot_api_version) { "5.0.6" }
  subject { VagrantPlugins::Utm::Driver::Meta.new(uuid) }

  it_behaves_like "a version 4.x utm driver"

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
