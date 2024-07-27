on run argv
  set vmID to item 1 of argv
    tell application "UTM"
        set vm to virtual machine id vmID
        set config to configuration of vm
        set networkInterfaces to network interfaces of config
        repeat with anInterface in networkInterfaces
            # if you start log with variable you'll get "," at the end of the log if '&' is used to concatenate
            log "nic" & index of anInterface & "," & mode of anInterface 
        end repeat
    end tell
end run