---
title: UTM Vagrant box gallery
# layout: default
parent: UTM Box
nav_order: 1
---

# UTM Vagrant Box Gallery

To work with Vagrant, a base VM (box) must have 
[certain features](https://developer.hashicorp.com/vagrant/docs/boxes/base), like an ssh user for vagrant to connect.

To help you get started with Vagrant UTM provider, a couple of pre-built VMs that work with Vagrant and are published in [HCP Vagrant registry](https://portal.cloud.hashicorp.com/vagrant/discover/utm).

{: .important}
All the VMs provided are built from [UTM Gallery VMs](https://mac.getutm.app/gallery/) or ISO in an (semi) automated way using [packer plugin for UTM][packer plugin for UTM]. Please see the [UTM Box Guide][UTM Box Guide] on how these UTM Vagrant boxes were built using packer.

* Debian 11 (Xfce):   
```ruby
config.vm.box = "utm/debian11"
```

* Ubuntu 24.04 :
```ruby
config.vm.box = "utm/ubuntu-24.04"
```

* Help build more boxes using [packer plugin for UTM][packer plugin for UTM]
<!-- * ArchLinux ARM -->


{: .new}
To enable building reproducible and easily sharable UTM VM bundle a [packer plugin for UTM][packer plugin for UTM] has been developed and open-sourced. 



Check out [Creating UTM Box](/creating_utm_box.md) to build your own compatible UTM Vagrant box.


[packer plugin for UTM]: https://github.com/naveenrajm7/packer-plugin-utm
[UTM Box Guide]: https://github.com/naveenrajm7/utm-box/blob/main/HowToBuild/DebianUTM.md