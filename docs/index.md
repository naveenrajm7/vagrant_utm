---
title: Home
layout: home
nav_order: 1
description: "Vagrant UTM plugin enables you to manage UTM VMs using Vagrant"
permalink: /
---

# Automate your VM setup on Mac
{: .fs-7 }

vagrant_utm is a [Vagrant][Vagrant] plugin which adds [UTM][UTM] provider to Vagrant, 
allowing Vagrant to control and provision machines via UTM's API.


[Get started now](#getting-started){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View it on GitHub][Vagrant UTM repo]{: .btn .fs-5 .mb-4 .mb-md-0 }

---

[UTM] is a free, full featured system emulator and virtual machine host for iOS and macOS.
The UTM provider currently supports UTM versions 4.5.x (except 4.5.0).

[Vagrant] enables the creation and configuration of lightweight, reproducible, and portable development environments using Vagrantfile. The UTM provider plugin works with Vagrant version 2.4.1 .


Both UTM and Vagrant must be installed prior to using this plugin.
* [Download UTM for Mac](https://mac.getutm.app)
* [Install Vagrant ](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)

Browse the docs to learn more about how to use this plugin.


## Getting started

Get started with Vagrant UTM plugin in 2 simple steps.  
Make sure both [Vagrant] and [UTM] are installed before your proceed.

{: .note}
UTM Vagrant plugin is built around the existing UTM API. Some action like Snapshot are not straightforward. Please check [Known Issues](/known_issues.md) before using this plugin.


### Install

Install vagrant_utm plugin.
```bash
vagrant plugin install vagrant_utm
```

### Use

#### Step 1
Option 1: Create a Vagrantfile and initiate the box

```
vagrant init utm/debian11
```

Option 2: Open the Vagrantfile and replace the contents with the following

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "utm/debian11"
end
```

#### Step 2
Bring up your virtual machine

```
vagrant up
```

Now start using your machine!

`vagrant ssh` to log into machine or forward ports to check your website or share folders and start developing.

Check [Commands](commands.md) for all supported Vagrant commands.
Check [Configuration](configuration.md) for more UTM provider config options.


## About the project

Vagrant UTM is &copy; {{ "now" | date: "%Y" }} by [Naveenraj Muthuraj](https://naveenrajm7.github.io).

### License

The Vagrant UTM plugin is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). However, it uses vagrant library and parts of the code from virtualbox plugin both of which are BSL.
Please be aware of this if you intend on redistributing this plugin. 

### Contributing

Bug reports and pull requests are welcome on GitHub at [Vagrant UTM repo]. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/naveenrajm7/vagrant_utm/blob/main/CODE_OF_CONDUCT.md).

#### Thank you to the contributors of Vagrant UTM Plugin!

<ul class="list-style-none">
{% for contributor in site.github.contributors %}
  <li class="d-inline-block mr-1">
     <a href="{{ contributor.html_url }}"><img src="{{ contributor.avatar_url }}" width="32" height="32" alt="{{ contributor.login }}"></a>
  </li>
{% endfor %}
</ul>

### Code of Conduct

Everyone interacting in the Vagrant UTM project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/naveenrajm7/vagrant_utm/blob/main/CODE_OF_CONDUCT.md).

[Vagrant UTM repo]: https://github.com/naveenrajm7/vagrant_utm
[UTM]: https://mac.getutm.app
[Vagrant]: https://www.vagrantup.com