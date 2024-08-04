# frozen_string_literal: true

require "isolated_environment"

module Unit
  class IsolatedEnvironment < ::IsolatedEnvironment
    def create_vagrant_env(options = nil)
      options = {
        cwd: @workdir,
        home_path: @homedir
      }.merge(options || {})

      Vagrant::Environment.new(options)
    end

    # This creates a file in the isolated environment. By default this file
    # will be created in the working directory of the isolated environment.
    def file(name, contents)
      @workdir.join(name).open("w+") do |f|
        f.write(contents)
      end
    end

    def vagrantfile(contents, root = nil)
      root ||= @workdir
      root.join("Vagrantfile").open("w+") do |f|
        f.write(contents)
      end
    end
  end
end
