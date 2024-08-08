---
title: UTM box gallery
# layout: default
parent: UTM Box
nav_order: 1
---

# UTM Box Gallery

To work with Vagrant, a base VM (box) must have 
[certain features](https://developer.hashicorp.com/vagrant/docs/boxes/base), like a ssh user for vagrant to connect.

To help you get started with Vagrant UTM provider, couple of pre-built VMs from the [UTM Gallery](https://mac.getutm.app/gallery/) are modified to work with Vagrant and are made available to use.


* Debian 11 (Xfce):   
```ruby
u.utm_file_url = https://github.com/naveenrajm7/utm-box/releases/download/debian-11/debian_vagrant_utm.zip 
```

<!-- * ArchLinux ARM -->


{: .new}
To enable building reproducible and easily sharable UTM VM bundle a [packer plugin for UTM](https://github.com/naveenrajm7/packer-plugin-utm) has been developed.
Please see the [UTM Box Guide](https://github.com/naveenrajm7/utm-box/blob/main/HowToBuild/DebianUTM.md) on how these UTM Vagrant boxes were built using packer.

## Corresponding VMs from UTM Gallery

<div class="content">
  <section class="gallery">
      <!-- <div class="gallery-item">
          <a href="{{ vm.url }}">
              <h3>ArchLinux ARM</h3>
              <h4><i class="fas fa-microchip"></i> ARM64 </h4>
              <img src="{{ site.baseurl }}/assets/images/screens/archlinux-logo.png" alt="Screenshot" class="screenshot" />
          </a>
      </div> -->
      <div class="gallery-item">
        <a href="">
            <h3>Debian 11 (Xfce)</h3>
            <h4><i class="fas fa-microchip"></i> ARM64 </h4>
            <img src="{{ site.baseurl }}/assets/images/screens/debian-11-xfce-arm64.png" alt="Screenshot" class="screenshot" />
        </a>
      </div>
  </section>
</div>

<style>
.gallery {
  display: flex;
  flex-flow: row wrap;
  justify-content: center;
  align-items: center;
}

.gallery .gallery-item {
  padding: 5px;
  width: 20em;
}

.gallery-item a {
  text-decoration: none;
  color: black;
}

.gallery h3, .gallery h4 {
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.gallery h3 {
  font-size: 1.2em;
}

.gallery h4 {
  margin: 10px 0 10px 0;
  font-size: 0.8em;
  font-weight: normal;
}

.gallery .image {
  width: 20em;
}

.gallery .screenshot {
  max-width: 100%;
  height: auto;
  display: block;
  box-shadow: 0 1px 0 #ccc, 0 1px 0 1px #eee;
  border-radius: 2px;
  margin-left: auto;
  margin-right: auto;
  background: #DDD url('data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2244%22%20height%3D%2212%22%20viewBox%3D%220%200%2044%2012%22%3E%3Ccircle%20cx%3D%226%22%20cy%3D%226%22%20r%3D%224%22%20fill%3D%22%23eee%22%20%2F%3E%3Ccircle%20cx%3D%2222%22%20cy%3D%226%22%20r%3D%224%22%20fill%3D%22%23eee%22%20%2F%3E%3Ccircle%20cx%3D%2238%22%20cy%3D%226%22%20r%3D%224%22%20fill%3D%22%23eee%22%20%2F%3E%3C%2Fsvg%3E') 4px 4px no-repeat;
  padding: 20px 0 0 0;
  position: relative;
}

.gallery .placeholder {
  padding-top: 75%;
}

.gallery li {
  padding: 5px 0 5px 0;
}

.gallery .button {
  padding-bottom: 5px;
  margin: 20px 0 20px 0;
  font-size: 1.5em;
}
</style>