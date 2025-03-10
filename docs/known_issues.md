---
title: Known Issues
nav_order: 7
---

# Known Issues

This plugin is built around the existing UTM API.
Hence there are things which are not ideal.

1. ~~vagrant up : Loads new VM by downloading zip file every time, and manually asks the user to confirm the download completion.~~   
~~Draw back -  UTM does not support import API.~~

2. ~~UUID : After importing VM , considers last VM in the list as the VM that was imported . So, if the intended VM is not last in the list , the plugin might customize other VM according to the Vagrantfile.~~
~~Draw back -  UTM import API should return UUID when imported.~~

3. ~~vagrant package: plugin just prints message to manually export the VM.
Draw back -  UTM does not expose export API. (UTM already has 'Share')~~

4. Hide: Any plugin action will bring up the main UTM window. However, a properly built UTM box with no display will run headless.

5. vagrant snapshot: Even though UTM does not have snapshot feature, this plugin has a experimental support for offline VM snapshots using qemu-img. 
The VM must be stopped, for any snapshot commands to work.
The snapshot only works for **single** qcow2 based VM images
