---
layout: default
title: Synced Folders
parent: Features
nav_order: 1
---

# Synced Folders

UTM Vagrant plugin has support for syncing multiple folders between host and guest machine.
The plugin implements [UTM QEMU VirtFS](https://docs.getutm.app/guest-support/linux/#virtfs) as the default synced folder implementation for UTM provider.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "utm/bookworm"
  config.vm.synced_folder "../test", "/vagrant-test"
end
```

Vagrant by default syncs the current folder where that Vagrantfile is, and you can access them at `/vagrant` in the guest.

{: .important}


## Other Vagrant options

Apart from the provider specific Sync options, Vagrant has components to provide sync folders feature using NFS and RSync. These features are also supported in UTM plugin.
Check all Vagrant provided sync options at [Vagrant synced folders](https://developer.hashicorp.com/vagrant/docs/synced-folders).