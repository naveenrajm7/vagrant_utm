---
title: Creating a UTM box
parent: UTM Box
nav_order: 2
---

# Creating a UTM Base Box

As with [every Vagrant Provider](https://developer.hashicorp.com/vagrant/docs/providers/basic_usage), the Vagrant UTM provider has a custom box format that is required to work with Vagrant and the UTM plugin.

{: .important }
The UTM bundle (.utm file) is the box format for Vagrant UTM provider. 
Because the current UTM API does not support importing utm file, we do not use vagrant box format (.box file).
We currently use `utm://downloadVM?url=` to import VM to UTM.


{: .note }
However, once UTM supports import, we should be able to package UTM files into box format and use the benefits of Vagrant boxes . For example, downloading the box once to spin up multiple VMs and using vagrant cloud to publish custom UTM boxes.


{: .warning } 
This is a reasonably advanced topic that a beginning user of Vagrant does not need to understand. If you are just getting started with Vagrant, skip this and use an [available box](/utm_box_gallery.md). If you are an experienced user of Vagrant and want to create your own custom boxes, this is for you.

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

## Building your own UTM boxes

By satisfying the [general guidance on creating vagrant boxes](https://developer.hashicorp.com/vagrant/docs/boxes/base) and the above [Virtual Machine](#virtual-machine) requirements you can use your VM with Vagrant UTM plugin.

Apart from manually building the boxes, you can also use the semi-automated way of building these boxes using [packer plugin for UTM](https://github.com/naveenrajm7/packer-plugin-utm).
The packer plugin has a builder and a post processor, which uses an existing UTM file, adds Vagrant specific stuff and packs the UTM file as a zip so it can be used by UTM Vagrant plugin.

Checkout [UTM Box Guide](https://github.com/naveenrajm7/utm-box/blob/main/HowToBuild/DebianUTM.md) to know how to build Box using packer.

## Using your own UTM boxes

Due to the limitation of UTM API, the plugin can only take a url pointing to the zip file.
So, you can use a local python server to host your UTM bundle in zip file

```bash
python3 -m http.server                                                                            
Serving HTTP on :: port 8000 (http://[::]:8000/) ...
```

Use in Vagrantfile
```ruby
Vagrant.configure("2") do |config|
  config.vm.provider :utm do |utm|
    utm.utm_file_url = "http://localhost:8000/debian_vagrant_utm.zip"
  end
end
```