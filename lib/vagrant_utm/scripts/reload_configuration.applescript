---
-- reload_configuration.applescript
-- Ask UTM to re-read a VM's configuration from disk (UTM 5.0.4+).
--
-- Useful after editing config.plist (or other files under the .utm bundle)
-- outside of AppleScript, so UTM picks up those changes.
-- The VM must be stopped (see UTM #7711).
--
-- Usage:
--   osascript reload_configuration.applescript <VM_UUID>

on run argv
  set vmID to item 1 of argv

  tell application "UTM"
    set vm to virtual machine id vmID
    reload configuration of vm
  end tell
end run
