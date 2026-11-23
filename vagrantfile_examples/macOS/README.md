# Creating a macOS Vagrant Box for UTM

Until [UTM Packer support](https://github.com/utmapp/UTM/pull/7125) is merged, boxes must be created manually.

## 1. Create a macOS VM in UTM

> We're using the latest macOS to avoid downloading an IPSW. If you need a specific version, download it from [ipsw.me](https://ipsw.me/product/Mac).

1. Open UTM and click **Create a New Virtual Machine**
2. Select **Virtualize** (not Emulate)
3. Choose **macOS 12+**
4. Skip IPSW selection — UTM will use your host's macOS version
5. Allocate resources:
   - RAM: 8GB+ recommended
   - CPU: 4+ cores recommended
6. Set storage size (64GB+ recommended)
7. Review and save
8. Click play to start the VM
9. Complete macOS setup wizard

## 2. Configure Guest for Vagrant

Boot the VM and complete the following steps inside the guest macOS.

### Create vagrant user

1. Open **System Settings** > **Users & Groups**
2. Create new user:
   - Username: `vagrant`
   - Password: `vagrant`
   - Account type: Administrator

### Enable Remote Login (SSH)

1. Open **System Settings** > **General** > **Sharing**
2. Enable **Remote Login**
3. Allow access for user `vagrant`

### Configure passwordless sudo

```bash
sudo visudo
```

Add this line at the end:

```
vagrant ALL=(ALL) NOPASSWD: ALL
```

### Add Vagrant SSH key

```bash
mkdir -p /Users/vagrant/.ssh
curl -L https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
  >> /Users/vagrant/.ssh/authorized_keys
chmod 700 /Users/vagrant/.ssh
chmod 600 /Users/vagrant/.ssh/authorized_keys
chown -R vagrant:staff /Users/vagrant/.ssh
```

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### (Optional) Install common tools

```bash
brew install git curl wget
```

### Shut down the VM

```bash
sudo shutdown -h now
```

## 3. Create Vagrant Box

### Locate VM files

UTM stores VMs at:

```
~/Library/Containers/com.utmapp.UTM/Data/Documents/
```

Or for non-sandboxed UTM:

```
~/Documents/UTM/
```

Find your VM's `.utm` bundle (e.g., `macOS-Sequoia.utm`).

### Create box

```bash
BOX_NAME="macOS26"
VM_NAME="macOS 26"  # Name as shown in UTM
UTM_DIR="$HOME/Library/Containers/com.utmapp.UTM/Data/Documents"

# Create metadata.json
echo '{"provider":"utm"}' > /tmp/metadata.json

# Create box archive
tar cvzf ~/$BOX_NAME.box \
  -C /tmp metadata.json \
  -C "$UTM_DIR" "$VM_NAME.utm"

rm /tmp/metadata.json
```

### Add box to Vagrant

```bash
vagrant box add ~/$BOX_NAME.box --name $BOX_NAME
```

Verify:

```bash
vagrant box list
# Boxes are stored in ~/.vagrant.d/boxes/
```

## 4. Use the Box

### Apple Virtualization Limitations

macOS VMs on Apple Silicon use the Apple Virtualization framework, which has different capabilities than QEMU VMs:

| Feature | QEMU VMs | Apple Virtualization |
|---------|----------|---------------------|
| NAT Port Forwarding | ✅ | ❌ |
| 9pfs/VirtFS | ✅ | ❌ |
| qemu-guest-agent | ✅ | ❌ |
| NFS (requires IP) | ✅ | ❌ |
| VirtioFS | ❌ | ✅ (via UTM GUI) |
| SSH | Port forward | mDNS hostname |

### Create Vagrantfile

```ruby
# -*- mode: ruby -*-
# frozen_string_literal: true

Vagrant.configure("2") do |config|
  config.vm.box = "macOS26"

  # Direct SSH via mDNS (Apple Virtualization uses shared networking)
  config.ssh.host = "vagrant-macos.local"
  config.ssh.port = 22
  config.ssh.username = "vagrant"
  config.ssh.insert_key = false

  # Disable default SSH port forwarding (not supported)
  config.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2222, disabled: true

  # Disable synced folders - use VirtioFS via UTM GUI instead
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :utm do |utm|
    utm.memory = 8192
    utm.cpus = 4
    utm.check_guest_additions = false
    utm.functional_9pfs = false
  end
end
```

### Start the VM

```bash
vagrant up --provider=utm
```

### Connect via SSH

```bash
vagrant ssh
# Or directly: ssh vagrant@vagrant-macos.local
```

### Stop and destroy

```bash
vagrant halt
vagrant destroy
```

## Shared Folders (VirtioFS)

Apple Virtualization supports VirtioFS for shared folders, but configuration must be done through UTM GUI:

1. Stop the VM
2. Open VM settings in UTM
3. Go to **Sharing**
4. Add a shared directory
5. Start the VM
6. In macOS guest, shared folders appear at `/Volumes/My Shared Files/`

See: https://docs.getutm.app/guest-support/macos/#virtiofs

## Naming Convention

Examples:
- `macOS26` (macOS 26 / Tahoe)
- `macOS15` (macOS 15 / Sequoia)
- `macOS14` (macOS 14 / Sonoma)

## Troubleshooting

### SSH connection refused

- Verify Remote Login is enabled in guest
- Check vagrant user has SSH access
- Confirm authorized_keys file has correct permissions
- Ensure mDNS is working: `ping vagrant-macos.local`

### mDNS hostname not resolving

- macOS guest hostname should match (check with `hostname` in guest)
- Both host and guest must be on same network
- Try: `dns-sd -B _ssh._tcp` to browse for SSH services

### VM won't start

- Ensure UTM is installed and running
- Check VM bundle wasn't corrupted during copy
- Verify enough disk space for VM

### "Operation not supported by the backend" error

This happens when using features not supported by Apple Virtualization:
- Port forwarding
- 9pfs synced folders
- IP address queries

Use the Vagrantfile above which disables unsupported features.
