---
-- remove_qemu_additional_args.applescript
-- This script removes specified qemu arguments from a specified UTM virtual machine.
-- Usage: osascript remove_qemu_additional_args.applescript <VM_UUID> --args <arg1> <arg2> ...
-- Example: osascript remove_qemu_additional_args.applescript A123 --args "-vnc 127.0.0.1:13" "-vnc..."

on run argv
  set vmId to item 1 of argv -- UUID of the VM

  -- Initialize variables
  set argsToRemove to {}
  set argsFlag to false

  -- Parse the --args arguments
  repeat with i from 2 to (count of argv)
    set currentArg to item i of argv
    if currentArg is "--args" then
      set argsFlag to true
    else if argsFlag then
      set end of argsToRemove to currentArg
    end if
  end repeat

  tell application "UTM"
    -- Get the VM and its configuration
    set vm to virtual machine id vmId -- Id is assumed to be valid
    set config to configuration of vm

    -- Get the current QEMU additional arguments
    set qemuAddArgs to qemu additional arguments of config

    -- Initialize a new list for the updated arguments
    set updatedArgs to {}

    -- Iterate through the current arguments and add all except the ones to remove
    repeat with arg in qemuAddArgs
      if arg is not in argsToRemove then
        set end of updatedArgs to arg
      end if
    end repeat

    -- Update the configuration with the new arguments list
    set qemu additional arguments of config to updatedArgs
    update configuration of vm with config
  end tell
end run