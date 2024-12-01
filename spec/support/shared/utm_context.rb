# frozen_string_literal: true

shared_context "utm" do # rubocop:disable Metrics/BlockLength
  include_context "unit"

  let(:utm_context) { true }
  let(:uuid) { "1234-abcd-5678-efgh" }
  let(:utm_version) { "4.5.0" }
  let(:subprocess) { double("Vagrant::Util::Subprocess") }
  let(:script_path) { File.expand_path("../../../lib/vagrant_utm/scripts/", __dir__) }
  let(:utmctl_path) { "/usr/local/bin/utmctl" }

  # this is a helper that returns a duck type suitable from a system command
  # execution; allows setting exit_code, stdout, and stderr in stubs.
  def subprocess_result(options = {})
    defaults = { exit_code: 0, stdout: "", stderr: "" }
    double("subprocess_result", defaults.merge(options))
  end

  before do
    # we don't want unit tests to ever run commands on the system; so we wire
    # in a double to ensure any unexpected messages raise exceptions
    stub_const("Vagrant::Util::Subprocess", subprocess)

    # drivers will blow up on instantiation if they cannot determine the
    # utm version, so wire this stub in automatically
    allow(subprocess).to receive(:execute)
      .with("osascript", "-e",
            'tell application "System Events" to return version of application "UTM"',
            an_instance_of(Hash))
      .and_return(subprocess_result(stdout: utm_version))

    # drivers also call vm_exists? during init;
    allow(subprocess).to receive(:execute)
      .with("osascript", File.join(script_path, "list_vm.js"),
            an_instance_of(Hash))
      .and_return(subprocess_result(stdout: '[{ "UUID": "1234-abcd-5678-efgh", "Name": "VmName",
                                               "Status": "stopped" }]'))

    allow(Vagrant::Util::Which).to receive(:which).and_call_original
    allow(Vagrant::Util::Which).to receive(:which).with("locale").and_return(false)
  end
end
