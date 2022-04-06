#!/bin/bash

# XXX:
#  Shamelessly taken from https://unix.stackexchange.com/a/465372

function in_subnet {
    # Determine whether IP address is in the specified subnet.
    #
    # Args:
    #   sub: Subnet, in CIDR notation.
    #   ip: IP address to check.
    #
    # Returns:
    #   1|0
    #
    local ip ip_a mask netmask sub sub_ip rval start end;
    
    # Define bitmask.
    local readonly BITMASK=0xFFFFFFFF;
    
    # Read arguments.
    IFS=/ read sub mask <<< "${1}";
    IFS=. read -a sub_ip <<< "${sub}";
    IFS=. read -a ip_a <<< "${2}";
    
    # Calculate netmask.
    netmask=$(($BITMASK<<$((32-$mask)) & $BITMASK));
    
    # Determine address range.
    start=0;
    for o in "${sub_ip[@]}";
    do
        start=$(($start<<8 | $o));
    done;
    
    start=$(($start & $netmask));
    end=$(($start | ~$netmask & $BITMASK));
    
    # Convert IP address to 32-bit number.
    ip=0;
    for o in "${ip_a[@]}";
    do
        ip=$(($ip<<8 | $o));
    done
    
    # Determine if IP in range.
    (( $ip >= $start )) && (( $ip <= $end )) && rval=0 || rval=1;
    
    return "${rval}";
}

# the following will have exit-status 0 if `ext_ip` is in `item.subnet` 
in_subnet "$@"
