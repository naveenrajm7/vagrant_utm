# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

RSpec.describe VagrantPlugins::Utm::Action::Import do # rubocop:disable Metrics/BlockLength
  let(:app) { double("app") }
  let(:state) { :test_state }
  let(:machine) { double("machine", state: double("state", id: state)) }
  let(:action_runner) { double("action_runner") }
  let(:env) do
    {
      machine: machine,
      action_runner: action_runner,
      destroy_on_error: destroy_on_error
    }
  end
  subject { described_class.new(app, {}) }

  describe "#recover" do # rubocop:disable Metrics/BlockLength
    context "when destroy_on_error is false" do
      let(:destroy_on_error) { false }
      it "does nothing" do
        expect(action_runner).to_not receive(:run)
        subject.recover(env)
      end
    end

    context "when destroy_on_error is true" do # rubocop:disable Metrics/BlockLength
      let(:destroy_on_error) { true }

      context "and machine is not_created" do
        let(:state) { Vagrant::MachineState::NOT_CREATED_ID }

        it "does nothing" do
          expect(action_runner).to_not receive(:run)
          subject.recover(env)
        end
      end

      context "and machine is created" do
        let(:state) { :started }

        it "runs the destroy action with the proper environment" do
          destroy_stack = double("destroy_stack")
          allow(VagrantPlugins::Utm::Action).to receive(:action_destroy) { destroy_stack }
          expect(action_runner).to receive(:run).with(destroy_stack, hash_including(
                                                                       config_validate: false,
                                                                       force_confirm_destroy: true,
                                                                       raw_action_name: :destroy,
                                                                       action_name: :machine_action_destroy
                                                                     ))
          subject.recover(env)
        end

        context "but a VagrantError was raised" do
          before do
            env["vagrant.error"] = Vagrant::Errors::VagrantError.new
          end

          it "does nothing" do
            expect(action_runner).to_not receive(:run)
            subject.recover(env)
          end
        end
      end
    end
  end
end
