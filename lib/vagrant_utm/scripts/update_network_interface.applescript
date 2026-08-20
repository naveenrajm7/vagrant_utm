---
-- update_network_interface.applescript
-- Update VLAN / DHCP settings on a UTM network interface (UTM 5.0.4+).
--
-- Usage:
--   osascript update_network_interface.applescript <VM_UUID> --index <N> [options]
--
-- Options (all optional; omitted values are left unchanged):
--   --vlan-guest-address <CIDR>          e.g. 192.168.222.0/24
--   --vlan-guest-address-ipv6 <prefix>   e.g. fec0::/64
--   --vlan-dhcp-start-address <IPv4>
--   --vlan-dhcp-end-address <IPv4>
--   --isolate-from-host <true|false>
--
-- These properties apply to shared/host network modes (see UTM #7710 / #3294).

on run argv
  set vmID to item 1 of argv
  set nicIndex to missing value
  set vlanGuestAddress to missing value
  set vlanGuestAddressIpv6 to missing value
  set vlanDhcpStartAddress to missing value
  set vlanDhcpEndAddress to missing value
  set isolateFromHost to missing value

  repeat with i from 2 to (count of argv)
    set currentArg to item i of argv
    if currentArg is "--index" then
      set nicIndex to item (i + 1) of argv as integer
    else if currentArg is "--vlan-guest-address" then
      set vlanGuestAddress to item (i + 1) of argv
    else if currentArg is "--vlan-guest-address-ipv6" then
      set vlanGuestAddressIpv6 to item (i + 1) of argv
    else if currentArg is "--vlan-dhcp-start-address" then
      set vlanDhcpStartAddress to item (i + 1) of argv
    else if currentArg is "--vlan-dhcp-end-address" then
      set vlanDhcpEndAddress to item (i + 1) of argv
    else if currentArg is "--isolate-from-host" then
      set isolateArg to item (i + 1) of argv
      if isolateArg is "true" or isolateArg is "yes" or isolateArg is "1" then
        set isolateFromHost to true
      else
        set isolateFromHost to false
      end if
    end if
  end repeat

  if nicIndex is missing value then
    error "Missing required --index <nicIndex>"
  end if

  tell application "UTM"
    set vm to virtual machine id vmID
    set config to configuration of vm
    set networkInterfaces to network interfaces of config
    set updated to false

    repeat with anInterface in networkInterfaces
      if nicIndex is index of anInterface then
        if vlanGuestAddress is not missing value then
          set vlan guest address of anInterface to vlanGuestAddress
        end if
        if vlanGuestAddressIpv6 is not missing value then
          set vlan guest address ipv6 of anInterface to vlanGuestAddressIpv6
        end if
        if vlanDhcpStartAddress is not missing value then
          set vlan dhcp start address of anInterface to vlanDhcpStartAddress
        end if
        if vlanDhcpEndAddress is not missing value then
          set vlan dhcp end address of anInterface to vlanDhcpEndAddress
        end if
        if isolateFromHost is not missing value then
          set isolate from host of anInterface to isolateFromHost
        end if
        set updated to true
      end if
    end repeat

    if updated is false then
      error "Network interface index " & nicIndex & " not found"
    end if

    -- VM must be stopped
    update configuration of vm with config
  end tell
end run
