---
layout: default
title: Status
parent: Internals
nav_order: 2
---

The Table below maps the vagrant (virtualbox) status to UTM status.



| Vagrant/VirtualBox | UTM |
| --- | --- |
| poweroff | stopped |
|  | starting |
| running | started |
|  | pausing |
| paused/saved | paused |
|  | resuming |
| stopping | stopping |
|  | unknown |

{: .warning } 
UTM does not report the state `running`, which usally means the VM is ready to accept commands.
Hence, wherever the state `running` is required by Vagrant, we cautiously use the state `started`.