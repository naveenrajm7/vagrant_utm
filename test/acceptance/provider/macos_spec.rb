# frozen_string_literal: true

require_relative "../base"

describe "provider/utm/macos", component: "provider/utm" do
  include_context "acceptance"
  include_context "provider-utm"

  before(:all) do
    environment.skeleton("macos")
  end

  after(:all) do
    # execute("vagrant", "destroy", "-f")
  end

  describe "vagrant up" do
    it "boots the VM" do
      result = execute("vagrant", "up", "--provider=utm")
      expect(result.exit_code).to eq(0)
    end
  end

  describe "ssh" do
    it "connects successfully" do
      result = execute("vagrant", "ssh", "-c", "uname -a")
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to include("Darwin")
    end
  end

  describe "homebrew" do
    it "is installed" do
      result = execute("vagrant", "ssh", "-c", "brew --version")
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(/Homebrew \d+/)
    end
  end

  describe "synced folder" do
    it "mounts at symlinked path" do
      result = execute("vagrant", "ssh", "-c", "test -f #{guest_path}/Vagrantfile")
      expect(result.exit_code).to eq(0)
    end

    it "syncs bidirectionally" do
      readme = File.join(environment.workdir, "README.md")
      FileUtils.rm_f(readme)

      execute("vagrant", "ssh", "-c", "echo '# Test' > #{guest_path}/README.md")

      expect(File.exist?(readme)).to be(true)
      FileUtils.rm_f(readme)
    end
  end
end
