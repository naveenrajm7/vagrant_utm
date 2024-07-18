on run argv
    tell application "UTM"
        set vmID to item 1 of argv
        set vmName to item 2 of argv
        set vm to virtual machine id vmID
        --- get the configuration of the vm
        set config to configuration of vm
        --- set name of the vm
        set name of config to vmName
        --- get current notes and append to the notes of the vm
        set currentNotes to notes of config
        set notes of config to currentNotes & "\n## This VM is created and managed by Vagrant ##"
        
        --- check if cpu and memory arguments are provided
        if (count of argv) ³ 3 then
            set cpuCount to item 3 of argv
            set cpu cores of config to cpuCount
        end if
        if (count of argv) ³ 4 then
            set memorySize to item 4 of argv
            set memory of config to memorySize
        end if
        
        --- save the configuration (VM must be stopped)
        update configuration of vm with config
    end tell
end run