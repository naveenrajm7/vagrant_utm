---
-- add_qemu_additional_args.applescript
-- This script adds qemu arguments to a specified UTM virtual machine.
-- Usage: osascript add_qemu_additional_args.applescript <VM_UUID> --args <arg1> <arg2> ...
-- Example: osascript add_qemu_additional_args.applescript A123 --args "-vnc 127.0.0.1:13" "-vnc..."

on run argv
  set vmId to item 1 of argv # UUID of the VM

  -- Initialize variables
  set argsList to {}
  set argsFlag to false

  -- Parse the --args arguments
  repeat with i from 2 to (count of argv)
    set currentArg to item i of argv
    if currentArg is "--args" then
      set argsFlag to true
    else if argsFlag then
      set end of argsList to currentArg
    end if
  end repeat

  tell application "UTM"
    -- Get the VM and its configuration
    set vm to virtual machine id vmId -- Id is assumed to be valid
    set config to configuration of vm

    -- Existing arguments
    set qemuAddArgs to qemu additional arguments of config

    -- Create new arguments from argsList and add them to the existing arguments
    repeat with arg in argsList
      set end of qemuAddArgs to {argument string:arg}
    end repeat

    --- set qemu args with new args list
    set qemu additional arguments of config to qemuAddArgs

    --- save the configuration (VM must be stopped)
    update configuration of vm with config
  end tell
end run