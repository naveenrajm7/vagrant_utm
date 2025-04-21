---
-- add_directory_share.applescript
-- This script adds QEMU arguments for directory sharing in UTM (QEMU) for given id and directory pairs.
-- Usage: osascript add_directory_share.applescript UUID --id <ID1> --dir <DIR1> --id <ID2> --dir <DIR2> ...
-- Example: osascript add_directory_share.applescript UUID --id no1 --dir "/path/to/dir1" --id no2 --dir "/path/to/dir2"

-- Function to create QEMU arguments for directory sharing
on createQemuArgsForDir(dirId, dirPath)

    -- Prepare the QEMU argument strings
    set fsdevArgStr to "-fsdev local,id=" & dirId & ",path=" & dirPath & ",security_model=mapped-xattr" 
    set deviceArgStr to "-device virtio-9p-pci,fsdev=" & dirId & ",mount_tag=" & dirId

    return {fsdevArgStr, deviceArgStr}
end createQemuArgsForDir

-- Main script
on run argv
    -- VM id is assumed to be the first argument
    set vmId to item 1 of argv 

    -- Initialize variables
    set idList to {} -- 
    set dirList to {}
    set idFlag to false
    set dirFlag to false

    -- Parse arguments
    repeat with i from 2 to (count of argv)
        set currentArg to item i of argv
        if currentArg is "--id" then
            set idFlag to true
            set dirFlag to false
        else if currentArg is "--dir" then
            set dirFlag to true
            set idFlag to false
        else if idFlag then
            set end of idList to currentArg
            set idFlag to false
        else if dirFlag then
            set end of dirList to currentArg
            set dirFlag to false
        end if
    end repeat

    -- Ensure the lists are of the same length
    if (count of idList) is not (count of dirList) then
        error "The number of IDs and directories must be the same."
    end if

    -- Initialize the list of QEMU arguments
    set qemuNewArgs to {}

    -- Initialize the directory list
    set directoryList to {}

    -- Create QEMU arguments for each directory
    repeat with i from 1 to (count of dirList)
        set dirPath to item i of dirList
        set dirId to item i of idList
        set dirURL to POSIX file dirPath
        set {fsdevArgStr, deviceArgStr} to createQemuArgsForDir(dirId, dirPath)

        -- add the directory file obj to the list
        set end of directoryList to dirURL
        -- append the arguments to the list
        set end of qemuNewArgs to {fsdevArg:fsdevArgStr, deviceArg:deviceArgStr, dirURL:dirURL}
    end repeat

    -- Example usage in UTM
    tell application  "UTM"
        set vm to virtual machine id vmId
        set config to configuration of vm

        -- Get the current QEMU additional arguments
        set qemuAddArgs to qemu additional arguments of config

        -- Add the new arguments to the existing ones
        repeat with arg in qemuNewArgs
        -- SKIP: adding file urls to qemu args file urls , since it is not necessary. UTM#6977
            set end of qemuAddArgs to {argument string:fsdevArg of arg}
            set end of qemuAddArgs to {argument string:deviceArg of arg}
        end repeat

        -- Update the configuration with the new arguments list
        set qemu additional arguments of config to qemuAddArgs
        update configuration of vm with config

        -- Get the current directory shares in registry
        set reg to registry of vm
        -- Add new directory shares to the registry
        set reg to reg & directoryList
        -- Update registry of vm with new directory shares
        update registry of vm with reg
    end tell
end run