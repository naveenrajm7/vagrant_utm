---
title: UTM Vagrant box gallery
# layout: default
parent: UTM Box
nav_order: 1
---

# UTM Box Gallery

To work with Vagrant, a base VM (box) must have 
[certain features](https://developer.hashicorp.com/vagrant/docs/boxes/base), like a ssh user for vagrant to connect.

To help you get started with Vagrant UTM provider, couple of pre-built VMs that work with Vagrant and are made available to use.

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

* More boxes. Coming Soon...
<!-- * ArchLinux ARM -->


{: .new}
To enable building reproducible and easily sharable UTM VM bundle a [packer plugin for UTM][packer plugin for UTM] has been developed and open-sourced. 



Check out [Creating UTM Box](/creating_utm_box.md) to build your own Vagrant compatible UTM box.


[packer plugin for UTM]: https://github.com/naveenrajm7/packer-plugin-utm
[UTM Box Guide]: https://github.com/naveenrajm7/utm-box/blob/main/HowToBuild/DebianUTM.md