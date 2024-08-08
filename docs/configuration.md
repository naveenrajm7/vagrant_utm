---
title: Configuration
nav_order: 3
---

# Configuration

The UTM provider exposes some additional configuration options that allow you to more finely control your UTM-powered Vagrant environments.

## Virtual Machine Name

You can customize the name that appears in the UTM GUI by setting the name property. By default, Vagrant sets it to the containing folder of the Vagrantfile plus a timestamp of when the machine was created. By setting another name, your VM can be more easily identified.

```ruby
config.vm.provider "utm" do |u|
  u.name = "my_vm"
end
```

## Other customization

```ruby
Vagrant.configure("2") do |config|
  # Hostname inside the VM
  config.vm.hostname = "debian"
  # Ports to forward
  config.vm.network "forwarded_port", guest: 80, host: 8989
  # Provider specific configs
  config.vm.provider "utm" do |u|
    # Name in UTM UI
    u.name = "debian"
    # UTM VM file to import
    u.utm_file_url = "http://localhost:8000/debian_vagrant_utm.zip"
    # CPU in cores
    u.cpus = 1
    # Memory in MB
    u.memory = 1024
    # Notes for UTM VM (Appears in UI)
    u.notes = "Vagrant: For testing plugin development"
    # QEMU Directoy Share mode for the VM. 
    # Takes none, webDAV or virtFS
    u.directory_share_mode = "webDAV"
  end
  # Provisioner config, supports all built provisioners
  # shell, ansible
  config.vm.provision "shell", inline: <<-SHELL
  apt-get update
  apt-get install -y apache2
  SHELL
end
```
