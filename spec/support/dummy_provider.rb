# frozen_string_literal: true

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

module VagrantTests
  class DummyProviderPlugin < Vagrant.plugin("2")
    name "Dummy Provider"
    description <<-DESCRIPTION
    This creates a provider named "dummy" which does nothing, so that
    the unit tests aren't reliant on UTM (or any other real
    provider for that matter).
    DESCRIPTION

    provider(:dummy) { DummyProvider }
  end

  class DummyProvider < Vagrant.plugin("2", :provider)
    def initialize(machine) # rubocop:disable Lint/MissingSuper
      @machine = machine
    end

    def state=(id)
      state_file.open("w+") do |f|
        f.write(id.to_s)
      end
    end

    def state
      unless state_file.file?
        new_state = @machine.id
        new_state ||= Vagrant::MachineState::NOT_CREATED_ID
        self.state = new_state
      end

      state_id = state_file.read.to_sym
      Vagrant::MachineState.new(state_id, state_id.to_s, state_id.to_s)
    end

    protected

    def state_file
      @machine.data_dir.join("dummy_state")
    end
  end
end
