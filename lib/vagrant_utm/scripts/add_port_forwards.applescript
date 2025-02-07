# Usage: osascript add_port_forwards.applescript UUID  --index 2 "protocol,guestIp,guestPort,hostIp,hostPort" --index 1 "UdPp,100,100,100,100"
# index is the index of the network interface
on run argv
  -- VM id is assumed to be the first argument
  set vmID to item 1 of argv 
  -- Initialize an empty list to store port forwarding rules
  set portForwardRules to {}

  -- Parse the arguments
  repeat with i from 2 to count of argv by 3
    set indexArg to item i of argv
    set indexNumber to item (i + 1) of argv
    set ruleArg to item (i + 2) of argv
    
    -- Index number is assume to point to 'emulated' network interface
    -- port forwarding does not work with other network interfaces
    -- even though the UTM API allows it
    set indexNumber to indexNumber as integer

    -- Port forwarding rules are assumed to be in the format
    --  "protocol,guestAddress,guestPort,hostAddress,hostPort"
    set AppleScript's text item delimiters to ","

    -- Split the rule argument into its components
    set ruleComponents to text items of ruleArg
    
    -- Create a port forwarding rule record
    set portForwardRule to { indexVal:indexNumber, protocolVal:item 1 of ruleComponents, guestAddress:item 2 of ruleComponents, guestPort:item 3 of ruleComponents, hostAddress:item 4 of ruleComponents, hostPort:item 5 of ruleComponents }
    
    -- Add the rule to the list
    set end of portForwardRules to portForwardRule
  end repeat

  -- Add port forwarding rules to the corresponding network interfaces
  tell application "UTM"
    set vm to virtual machine id vmID
    set config to configuration of vm

    set networkInterfaces to network interfaces of config
    repeat with anInterface in networkInterfaces
      set netIfIndex to index of anInterface
      repeat with portForwardRule in portForwardRules
        if (indexVal of portForwardRule) as integer is netIfIndex then
          -- Existing port forwards
          set portForwards to port forwards of anInterface
          
          -- Create a new port forward configuration
          set newPortForward to { protocol:(protocolVal of portForwardRule), guest address:(guestAddress of portForwardRule), guest port:(guestPort of portForwardRule), host address:(hostAddress of portForwardRule), host port:(hostPort of portForwardRule) }
          
          -- Add new port forward to the list
          copy newPortForward to the end of portForwards
          
          -- Update the port forwards for the current interface
          set port forwards of anInterface to portForwards
        end if
      end repeat
    end repeat
    
    -- Update the VM configuration
    update configuration of vm with config
  end tell
end run
