#!/bin/bash

#ssh Params
deliveryControllerIP="$1"
xenAdmin="$2"

#site Params
brokerVMName="$3"
desktopGroupName="$4"
machineCatalogName="$5"

#container Params
containerName="$6"
containerPort="${7:-"$(docker port "$containerName" | cut -d \: -f 2)"}"

hostVMIP=`(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')`

ssh "$xenAdmin"@"$deliveryControllerIP" 'powershell "C:\createXenContainer.ps1 '"$hostVMIP"' '"$containerPort"' '"$containerName"' '"$brokerVMName"' '"$desktopGroupName"' '"$machineCatalogName"'"'


