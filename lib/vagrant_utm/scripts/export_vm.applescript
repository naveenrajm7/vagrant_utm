# Usage: osascript export_vm.applescript <vmUUID> <filePath>
# vmID is the uuid of the virtual machine
# filePath is the path where the exported file will be saved
on run argv
  set vmID to item 1 of argv
  set exportPath to item 2 of argv
  set exportFile to POSIX file exportPath

  tell application "UTM"
    set vm to virtual machine id vmID
    export vm to exportFile
  end tell
end run