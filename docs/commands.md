---
layout: default
title: Commands (CLI)
nav_order: 2
---

# Commands (CLI)
{: .no_toc }

This page lists all the supported Vagrant commands which depend on the  UTM provider. Eg. `up`, `suspend`, `resume`, `halt`.

Adds notes to commands which have provider-specific behavior. Eg. `snapshot`.

The Vagrant commands that do not depend on provider are not listed and will continue to work. Eg. `global-status`

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}


---

## **Box**

**Command: `vagrant box`**

UTM provider uses .utm file as VM bundle and supports box operations. 

## **Destroy**

**Command: `vagrant destroy [name|id]`**

```utmctl delete```

## **Halt**

**Command: `vagrant halt [name|id]`**

```utmctl stop```

## **Package**

**Command: `vagrant package [name|id]`**

UTM 'Share' / export

## **Port**

**Command: `vagrant port [name|id]`**

The port command displays the full list of guest ports mapped to the host machine ports:



## **Provision**

**Command: `vagrant provision [vm-name]`**

Runs any configured [provisioners](https://developer.hashicorp.com/vagrant/docs/provisioning) against the running Vagrant managed machine



## **Reload**

**Command: `vagrant reload [name|id]`**

The equivalent of running a [halt](https://developer.hashicorp.com/vagrant/docs/cli/halt) followed by an [up](https://developer.hashicorp.com/vagrant/docs/cli/up).



## **Resume**

**Command: `vagrant resume [name|id]`**

This resumes a Vagrant managed machine that was previously suspended, perhaps with the [suspend command](https://developer.hashicorp.com/vagrant/docs/cli/suspend).

```utmctl start```



## **Snapshot**

**Command: `vagrant snapshot`**

`utmctl snapshot`

With UTM 5.0.6 or newer, the provider uses UTM's native named snapshots.
UTM supports QEMU snapshots on macOS. Apple Virtualization snapshots require
macOS 27. A snapshot of a running QEMU VM includes its running state; a
snapshot of a stopped VM saves its disks. UTM handles saving, listing, and
deleting snapshots through its native API.

`vagrant snapshot restore` stops a running VM before restoring its snapshot.
Vagrant starts the restored VM afterward unless `--no-start` is given. UTM may
resume saved RAM state when the restored VM next starts. The provider does not call
`utmctl discard-state` during a restore, because that would discard the saved
running state.

Older UTM releases do not expose the 5.0.6 snapshot API. This plugin no longer uses
`qemu-img` as a fallback. If you need snapshots on UTM older than 5.0.6,
keep the previous plugin version that paired with that UTM release.


## **SSH**

**Command: `vagrant ssh [name|id] [-- extra_ssh_args]`**



## **SSH Config**

**Command: `vagrant ssh-config [name|id]`**



## **Status**

**Command: `vagrant status [name|id]`**

`utmctl status`



## **Suspend**

**Command: `vagrant suspend [name|id]`**

`utmctl suspend`



## **Up**

**Command: `vagrant up [name|id]`**

Import VM (if not created)

`utmctl start`



## **Upload**

**Command: `vagrant upload source [destination] [name|id]`**



# **Custom Commands**

These are the commands not available in vagrant but specific to UTM provider.

## IP Address

**Command: `vagrant ip-address [name|id]`**

`utmctl ip-address`

List all IP addresses associated with network interfaces on the guest.

## Disposable

**Command: `vagrant disposable [name|id]`**

`utmctl start --disposable`

Start virtual machine in disposable mode, which allows you to run a virtual machine without saving any persistent changes to the drive.

Read about Disposable mode in [UTM docs](https://docs.getutm.app/advanced/disposable/)
