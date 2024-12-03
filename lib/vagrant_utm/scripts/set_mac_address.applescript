# This script sets the MAC address of a network interface in a specified UTM virtual machine.
# Usage: osascript set_mac_address.applescript <VM_UUID> <NIC_INDEX> <MAC_ADDRESS>
# Example: osascript set_mac_address.applescript A123 1 XX:XX:XX:XX:XX:XX
on run argv
  set vmID to item 1 of argv
  set nicIndex to item 2 of argv
  set macAddress to item 3 of argv

  tell application "UTM"
    set vm to virtual machine id vmID
    set config to configuration of vm
    set networkInterfaces to network interfaces of config

    repeat with anInterface in networkInterfaces
      if nicIndex as integer is index of anInterface then
        -- Set the provided MAC address
        set address of anInterface to macAddress
      end if
    end repeat

    -- Update the VM configuration
    update configuration of vm with config
  end tell
  
end run