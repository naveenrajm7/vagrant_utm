on run argv
  set vmID to item 1 of argv
    tell application "UTM"
        set vm to virtual machine id vmID
        set config to configuration of vm

        set networkInterfaces to network interfaces of config
        repeat with anInterface in networkInterfaces
            if (mode of anInterface as string) is "emulated" then
                set portForwards to port forwards of anInterface
                set i to -1
                repeat with aPortForward in portForwards
                    set i to i + 1
                    # Log the port forward details Virtualbox style 'Forwarding(0)="tcp,,8000,,2080"'
                    log "Forwarding(" & i & ")=\"" & protocol of aPortForward & "," Â
                        & guest address of aPortForward & "," & guest port of aPortForward & "," Â
                        & host address of aPortForward & "," & host port of aPortForward & "\""
                end repeat
            end if
        end repeat
    end tell
end run