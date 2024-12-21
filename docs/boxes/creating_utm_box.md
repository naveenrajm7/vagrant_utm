---
title: Creating a UTM box
parent: UTM Box
nav_order: 2
---

# Creating a UTM Base Box

As with [every Vagrant Provider](https://developer.hashicorp.com/vagrant/docs/providers/basic_usage), the Vagrant UTM provider has a custom box format that is required to work with Vagrant and the UTM plugin.

## UTM Vagrant box format

UTM file (in macOS) is a directory containing Data/qcow2 (s), Data/efi_vars.fd and config.plist.
Vagrant Box format will require additional metadata.json file. 

Vagrant .box is a tar file

The contents of a `utm/ubuntu-24.04` vagrant box.
```bash
$tar -tf ubuntu-24.04.box 
Vagrantfile
box.utm/Data/7FB247A3-DC9F-4A61-A123-0AEE1BEEC636.qcow2
box.utm/Data/efi_vars.fd
box.utm/config.plist
box.utm/screenshot.png
metadata.json
```

{: .warning } 
This is a reasonably advanced topic that a beginning user of Vagrant does not need to understand. If you are just getting started with Vagrant, skip this and use an [available box](/utm_box_gallery.md). If you are an experienced user of Vagrant and want to create your own custom boxes, this is for you.

## Virtual Machine

The virtual machine created in UTM can use any configuration you would like, but Vagrant has some hard requirements:

* The first network interface (adapter 1 or index 0) must be `Shared Network`, which is recommended for new virtual machines. 

We use 'Shared Network' as a NAT equivalent in Vagrant.

* The second network interface (adapter 2 or index 1) must be a `Emulated VLAN` adapter. Vagrant uses this to connect the first time via forwarded ports.

We use 'Emulated VLAN' to achieve port forwarding.




Other than the above, you are free to customize the base virtual machine as you see fit.

## Additional Software

In addition to the software that should be installed based on the [general guide to creating base boxes](https://developer.hashicorp.com/vagrant/docs/boxes/base), UTM base boxes require some additional software.

### UTM Guest Support

In order to take full advantage of all the features UTM has to offer, you need to install some software in the virtual machine guest.

Check the [UTM Guide on Guest Support](https://docs.getutm.app/guest-support/guest-support/) to install software based on your guest operating system.

## Building your own UTM boxes

By satisfying the [general guidance on creating vagrant boxes](https://developer.hashicorp.com/vagrant/docs/boxes/base) and the above [Virtual Machine](#virtual-machine) requirements you can use your VM with Vagrant UTM plugin.

Apart from manually building the boxes, you can also use the automated (almost) way of building these boxes using [packer plugin for UTM](https://github.com/naveenrajm7/packer-plugin-utm).
The packer plugin has the following components:
1. Builder
    1. UTM - Use existing utm file 
    2. ISO - Start from scratch using ISO files  
    3. CLOUD - Use existing qcow2 cloud images
2. Post-processor
    1. ZIP - Package UTM VM into zip file
    2. Vagrant - Package UTM VM into vagrant box.


Checkout [UTM Box Packer recipe](https://github.com/naveenrajm7/utm-box?tab=readme-ov-file#building-boxes) to know how to build Box using packer.

## Using your own UTM VMs

Do you have your own UTM VM that you would like to use with Vagrant 

1. Convert your utm file to box format

    a. Make a directory  
    b. Put utm vm file in it  
    c. Tar the folder with .box extension

2. Import the vagrant box 
```bash
vagrant box add --name custom/debian debian.box  
```

3. Use in Vagrantfile
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "custom/debian11"
end
```

You can also use [packer plugin for UTM](https://github.com/naveenrajm7/packer-plugin-utm) to build, package and publish your UTM VMs to HCP Vagrant registry and share it your teams or with the world.