# frozen_string_literal: true

RSpec.describe VagrantPlugins::Utm do
  subject(:sut) { described_class }

  it "has a version number" do
    expect(sut::VERSION).not_to be nil
  end
end
