# frozen_string_literal: true

RSpec.describe VagrantPlugins::Utm::Config do
  subject(:sut) { described_class.new }

  context "defaults" do
    before { subject.finalize! }

    it { expect(subject.check_guest_additions).to be(true) }
    it { expect(subject.name).to be_nil }
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
