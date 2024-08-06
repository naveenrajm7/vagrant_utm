# frozen_string_literal: true

RSpec.shared_examples "a version 4.x utm driver" do |_options|
  before do
    raise ArgumentError, "Need utm context to use these shared examples." unless defined? utm_context
  end

  describe "read_guest_ip" do
    it "reads the guest IP" do
      expect(subprocess).to receive(:execute)
        .with("osascript",
              "/Users/naveenrajm/Developer/UTMvagrant/vagrant_utm/lib/vagrant_utm/scripts/read_guest_ip.applescript",
              uuid, an_instance_of(Hash))
        .and_return(subprocess_result(stdout: "192.168.69.1"))

      value = subject.read_guest_ip

      expect(value).to eq("192.168.69.1")
    end
  end
end
