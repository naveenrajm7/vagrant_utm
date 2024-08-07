---
layout: default
title: UTM API
parent: Internals
nav_order: 3
---

The plugin invokes UTM API inorder to implement Vagrant required actions.
As there are several ways to control UTM, we use the following order

1. UTM Command Line (`utmctl`) 
2. Apple Scripting Bridge (`osascript`)   
  2.a Applescript  
  2.b JavaScript
3. Shell command


**1. UTM Command Line** : Just like virtualbox plugin uses VBoxManage, the goal of this plugin is to use UTM command line tool `utmctl` as single point of control.

**2. Apple Scripting Bridge** :
However, not all capabilities are currently exposed via `utmctl`.
So we rely on Apple Scripting Bridge scripts which can be executed using `osascript` binary. 
When it comes to writing the OSA scripts, our first choice is applescript language due to its simplicity and support.
But, if we need to exchange complex data like json from UTM to plugin we use Javascript (Note: Some APIs are difficult to get it working in JS, hence our first choice is applescript).

**3. Shell command** : 
All interactions with UTM should be possible with `utmctl` or `osascript`. But, due to the unavailablity of certain commands or features, we work around the issue by using direct shell command.  
For Example:

* Import `open -g utm://downloadVM?url=...` 
* Snapshot `qemu-img snapshot ...`