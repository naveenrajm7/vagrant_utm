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
config.vm.provider "utm" do |u|
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
```