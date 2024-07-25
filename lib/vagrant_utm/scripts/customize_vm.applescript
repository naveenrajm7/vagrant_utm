on run argv
    tell application "UTM"
        set vmID to item 1 of argv -- VM id is given as the first argument
        set vmName to ""
        set cpuCount to 0
        set memorySize to 0
        set vmNotes to ""

        -- Parse arguments
        repeat with i from 2 to (count argv)
            set currentArg to item i of argv
            if currentArg is "--name" then
                set vmName to item (i + 1) of argv
            else if currentArg is "--cpus" then
                set cpuCount to item (i + 1) of argv
            else if currentArg is "--memory" then
                set memorySize to item (i + 1) of argv
            else if currentArg is "--notes" then
                set vmNotes to item (i + 1) of argv
            end if
        end repeat
        
        -- Get the VM and its configuration
        set vm to virtual machine id vmID -- ID is assumed to be valid
        set config to configuration of vm
        
        -- Set VM name if provided
        if vmName is not "" then
            set name of config to vmName
        end if
        
        -- Set CPU count if provided
        if cpuCount is not 0 then
            set cpu cores of config to cpuCount
        end if
        
        -- Set memory size if provided
        if memorySize is not 0 then
            set memory of config to memorySize
        end if
        
        -- Set the notes if --notes is provided (existing notes will be overwritten)
        if vmNotes is not "" then
            set notes of config to vmNotes
        end if

        -- Save the configuration
        update configuration of vm with config
 
    end tell
end run