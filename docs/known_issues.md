---
title: Known Issues
nav_order: 7
---

# Known Issues

This plugin was built built around the existing UTM API.
Hence there are things which are not ideal.

1. vagrant up : Loads new VM by downloading zip file every time. 
Draw back -  UTM does not support import API.

2. UUID : After importing VM , considers last VM in the list as the VM that was imported 

3. vagrant package: plugin just prints message to manually export the VM.
Draw back -  UTM does not expose export API. (UTM already has 'Share')

4. Hide: Any plugin action will bring up the main UTM window. However, a properly built UTM box with no display will run headless.

5. vagrant snapshot: Even though UTM does not have snapshot feature, this plugin has a experimental support for offline VM snapshots using qemu-img. 
The VM must be stopped, for any snapshot commands to work.
The snapshot only works for **single** qcow2 based VM images