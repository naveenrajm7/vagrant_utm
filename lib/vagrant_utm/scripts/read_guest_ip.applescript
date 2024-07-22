on run argv
  set vmID to item 1 of argv
  tell application "UTM"
      set vm to virtual machine id vmID
      --- get IP address (QEMU Guest Agent must be installed) of first interface
      get item 1 of (query ip of vm) -- Result: "192.168.64.9"
  end tell
end run

