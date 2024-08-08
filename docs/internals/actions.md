---
layout: default
title: Actions
parent: Internals
nav_order: 1
---

The Table below maps the vagrant commands to the corresponding UTM commands that are executed.

| Vagrant               | utmctl / AppleScript |
| ---                   | ------------------ | 
| `vagrant up`          | `utmctl start` | 
| `vagrant halt`        | `utmctl stop` |
| `vagrant suspend`     | `utmctl suspend` | 
| `vagrant resume`      | `utmctl start` | 
| `vagrant reload`      |  update configuration of vm with config |
| `vagrant destroy`     | `utmctl delete` | 
| `vagrant status`      | `utmctl status` | 
| `vagrant disposable`  | `utmctl start --disposable` | 
| `vagrant snapshot`    | `qemu-img snapshot`         |