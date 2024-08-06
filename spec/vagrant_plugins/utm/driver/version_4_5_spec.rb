# frozen_string_literal: true

require_relative "../base"

RSpec.describe VagrantPlugins::Utm::Driver::Version_4_5 do
  include_context "utm"
  let(:utm_version) { "4.5.3" }
  subject { VagrantPlugins::Utm::Driver::Meta.new(uuid) }

  it_behaves_like "a version 4.x utm driver"
end
