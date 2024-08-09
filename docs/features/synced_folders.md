---
layout: default
title: Synced Folders
parent: Features
nav_order: 1
---

# Synced Folders

UTM Vagrant plugin currently gives rudimentary support for syncing folders between host and guest machine.
The plugin provides option to configure the Qemu directory share mode. 
After which the the host directory can be selected from UTM UI, and the guest directory can be mounted in guest OS. Both of these steps are now manual until UTM exposes API to configure Host/Guest directory.

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider :utm do |u|
    u.utm_file_url = "https://github.com/naveenrajm7/utm-box/releases/download/debian-11/debian_vagrant_utm.zip"
    # QEMU Directoy Share mode for the VM. 
    # Takes none, webDAV or virtFS
    u.directory_share_mode = "webDAV"
  end
end
```

## Other Vagrant options

{: .important}
Apart from the provider specific Sync options, Vagrant has components to provide sync folders feature using NFS and RSync. These features are not yet supported in UTM plugin.
