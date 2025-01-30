# Usage: osascript read_forwarded_ports.applescript <vmID>
# vmID is the id of the virtual machine
# This script reads the port forwards of the 'emulated' network interface
# 'Forwarding(nicIndex)(ruleIndex)="protocol,guestAddress,guestPort,hostAddress,hostPort"'
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
                    # Log the port forward details Virtualbox style 
                    # 'Forwarding(nicIndex)(ruleIndex)="protocol,guestAddress,guestPort,hostAddress,hostPort"'
                    log "Forwarding(" & index of anInterface & ")(" & i & ")=\"" & protocol of aPortForward & "," & guest address of aPortForward & "," & guest port of aPortForward & "," & host address of aPortForward & "," & host port of aPortForward & "\""
                end repeat
            end if
        end repeat
    end tell
end run
