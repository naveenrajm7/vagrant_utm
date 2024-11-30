# Usage: osascript import_vm.applescript <filePath>
# filePath is the path of the file to import
# Returns the imported virtual machine
on run argv
  set importFile to item 1 of argv
  -- Convert the file path to a POSIX file
  -- This should be done outside the tell block
  set vmFile to POSIX file importFile

  tell application "UTM"
    set vm to import new virtual machine from vmFile
    return vm
  end tell
end run
