# Usage: osascript clear_port_forwards.applescript <vmID> --index <index> <hostPort> --index <index> <hostPort> ...
# index is the index of the network interface
# hostPort is the host port to remove from the port forwards
on run argv
  -- VM id is assumed to be the first argument
  set vmID to item 1 of argv 
    -- Initialize an empty list to store port forwarding rules to be deleted
    set portForwardRules to {}

    -- Parse the arguments
    repeat with i from 2 to count of argv by 3
        set indexArg to item i of argv
        set indexNumber to item (i + 1) of argv
        set hostPortArg to item (i + 2) of argv
        
        -- Assumed the index to be 'emulated' network interface
        set indexNumber to indexNumber as integer
        
        -- Create record of index and host port to remove
        set portForwardRule to {indexVal:indexNumber, hostPort:hostPortArg}
        
        -- Add the rule to the list
        set end of portForwardRules to portForwardRule
    end repeat

  -- Add port forwarding rules to the corresponding network interfaces
  tell application "UTM"
    set vm to virtual machine id vmID
    set config to configuration of vm

    set networkInterfaces to network interfaces of config
    repeat with anInterface in networkInterfaces
      repeat with portForwardRule in portForwardRules
        if (index of anInterface) is (indexVal of portForwardRule as integer) then
          -- Existing port forwards
          set portForwards to port forwards of anInterface
          
          -- Find and remove the port forward with the specified host port
          set updatedPortForwards to {}
          repeat with aPortForward in portForwards
            # Dont add the port forward if the host port matches the specified host port
            if (host port of aPortForward) is not (hostPort of portForwardRule as integer) then
                set end of updatedPortForwards to aPortForward
            end if
          end repeat
          
          -- Update the port forwards for the current interface
          set port forwards of anInterface to updatedPortForwards
        end if
      end repeat
    end repeat
    
    -- Update the VM configuration
    update configuration of vm with config
  end tell
end run