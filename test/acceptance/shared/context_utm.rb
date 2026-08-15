# frozen_string_literal: true

shared_context "provider-utm" do
  let(:provider) { "utm" }

  let(:guest_path) do
    "/Users/vagrant/#{environment.workdir.to_s.sub(%r{^/Users/[^/]+/}, "")}"
  end

  let(:skeleton_path) do
    Pathname.new(File.expand_path("../skeletons", __dir__))
  end
end
