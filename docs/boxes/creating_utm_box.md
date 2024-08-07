---
title: Creating a UTM box
parent: UTM Box
nav_order: 1
---

# Creating a UTM Base Box

As with [every Vagrant Provider](https://developer.hashicorp.com/vagrant/docs/providers/basic_usage), the Vagrant UTM provider has a custom box format that is required to work with Vagrant and the UTM plugin.

{: .important }
The UTM bundle (.utm file) is the box format for Vagrant UTM provider. 
Because the current UTM API does not support importing utm file, we do not use vagrant box format (.box file).
We currently use `utm://downloadVM?url=` to import VM to UTM.


{: .note }
However, once UTM supports import, we should be able to package UTM files into box format and use the benefits of Vagrant boxes . For example, downloading the box once to spin up multiple VMs. Using vagrant cloud to publish custom UTM boxes.


{: .warning } 
This is a reasonably advanced topic that a beginning user of Vagrant does not need to understand. If you are just getting started with Vagrant, skip this and use an [available box](../utm_box_gallery.md). If you are an experienced user of Vagrant and want to create your own custom boxes, this is for you.

## Virtual Machine

The virtual machine created in UTM can use any configuration you would like, but Vagrant has some hard requirements:

* The second network interface (adapter 1 or index 1) must be a `Emulated VLAN` adapter. Vagrant uses this to connect the first time.

* Use can use the first network interface (adapter 0 or index 0) to be `Shared Network`, which is recommended for new virtual machines. 

Other than the above, you are free to customize the base virtual machine as you see fit.

## Additional Software

In addition to the software that should be installed based on the [general guide to creating base boxes](https://developer.hashicorp.com/vagrant/docs/boxes/base), UTM base boxes require some additional software.

### UTM Guest Support

In order to take full advantage of all the features UTM has to offer, you need to install some software in the virtual machine guest.

Check the [UTM Guide on Guest Support](https://docs.getutm.app/guest-support/guest-support/) to install software based on your guest operating system.