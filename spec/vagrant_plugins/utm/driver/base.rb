# frozen_string_literal: true

require "vagrant_utm/driver/base"

RSpec.describe VagrantPlugins::Utm::Driver::Base do # rubocop:disable Metrics/BlockLength
  describe "#env_lang" do # rubocop:disable Metrics/BlockLength
    context "when locale command is not available" do
      before do
        allow(Vagrant::Util::Which).to receive(:which).with("locale").and_return(false)
        # stubbing call in initialize method
        allow(Vagrant::Util::Which).to receive(:which).with("utmctl").and_return("/path/to/utmctl")
      end

      it "should return default value" do
        expect(subject.send(:env_lang)).to eq({ LANG: "C" })
      end
    end

    context "when the locale command is available" do # rubocop:disable Metrics/BlockLength
      let(:result) { Vagrant::Util::Subprocess::Result.new(exit_code, stdout, stderr) }
      let(:stderr) { "" }
      let(:stdout) { "C.default" }
      let(:exit_code) { 0 }

      before do
        allow(Vagrant::Util::Which).to receive(:which).with("locale").and_return(true)
        # stubbing call in initialize method
        allow(Vagrant::Util::Which).to receive(:which).with("utmctl").and_return("/path/to/utmctl")
        allow(Vagrant::Util::Subprocess).to receive(:execute).with("locale", "-a").and_return(result)
      end

      context "when locale command errors" do
        let(:exit_code) { 1 }

        it "should return default value" do
          expect(subject.send(:env_lang)).to eq({ LANG: "C" })
        end
      end

      context "when locale command does not error" do
        let(:exit_code) { 0 }
        let(:base) do
          "de_AT.utf8\nde_BE.utf8\nde_CH.utf8\nde_DE.utf8\nde_IT.utf8\nde_LI.utf8\nde_LU.utf8\nen_AG\nen_AG.utf8\nen_AU.utf8\nen_BW.utf8\nen_CA.utf8\nen_DK.utf8\nen_GB.utf8\nen_HK.utf8\nen_IE.utf8\nen_IL\nen_IL.utf8\nen_IN\nen_IN.utf8\nen_NG\n" # rubocop:disable Layout/LineLength
        end

        context "when stdout includes C" do
          let(:stdout) { "#{base}C\n" }

          it "should use C for the lang" do
            expect(subject.send(:env_lang)).to eq({ LANG: "C" })
          end
        end
      end
    end
  end
end
