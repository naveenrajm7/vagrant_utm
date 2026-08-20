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

## Checking for Guest Additions

By default UTM plugin will check for the `qemu-guest-agent` when starting a machine, and will output a warning if the guest additions are not detected. You can skip the guest additions check by setting the check_guest_additions option:

```ruby
config.vm.provider "utm" do |u|
  u.check_guest_additions = false
end
```

## Shared network VLAN / DHCP (UTM 5.0.4+)

UTM 5.0.4 exposed AppleScript properties for the shared/host network VLAN subnet and DHCP pool ([utmapp/UTM#7710](https://github.com/utmapp/UTM/pull/7710)), so you no longer need to set them manually in the UTM UI ([utmapp/UTM#3294](https://github.com/utmapp/UTM/issues/3294)).

Index `0` is typically the first (Shared Network) adapter used by Vagrant boxes:

```ruby
config.vm.provider "utm" do |u|
  u.network_interface 0,
    vlan_guest_address: "192.168.222.0/24",
    vlan_dhcp_start_address: "192.168.222.2",
    vlan_dhcp_end_address: "192.168.222.254",
    isolate_from_host: false
end
```

Optional keys: `vlan_guest_address`, `vlan_guest_address_ipv6`, `vlan_dhcp_start_address`, `vlan_dhcp_end_address`, `isolate_from_host`.

You can also call the driver directly when the machine already exists:

```ruby
machine.provider.driver.update_network_interface(
  0,
  vlan_guest_address: "192.168.222.0/24",
  vlan_dhcp_start_address: "192.168.222.2",
  vlan_dhcp_end_address: "192.168.222.254"
)
```

## Reload configuration from disk (UTM 5.0.4+)

If a customize step edits `config.plist` (or other files under the `.utm` bundle) outside AppleScript, UTM keeps a cached copy until you ask it to reload ([utmapp/UTM#7711](https://github.com/utmapp/UTM/pull/7711)). The VM must be stopped:

```ruby
config.vm.provider "utm" do |u|
  # ... customize that edits files on disk ...
  u.reload_configuration
end
```

Or via the driver: `machine.provider.driver.reload_configuration`.

## Other customization

```ruby
Vagrant.configure("2") do |config|
  # Vagrant box 
  config.vm.box = "utm/debian11"
  # Hostname inside the VM
  config.vm.hostname = "debian"
  # Ports to forward
  config.vm.network "forwarded_port", guest: 80, host: 8989
  # Provider specific configs
  config.vm.provider "utm" do |u|
    # Name in UTM UI
    u.name = "debian"
    # CPU in cores
    u.cpus = 1
    # Memory in MB
    u.memory = 1024
    # VM icon (Available icons https://github.com/utmapp/UTM/tree/main/Icons)
    u.icon = "debian"
    # Notes for UTM VM (Appears in UTM UI)
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
