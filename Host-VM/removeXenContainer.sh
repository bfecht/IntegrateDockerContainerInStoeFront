#ssh Params
deliveryControllerIP="$1"
xenAdmin="$2"

#site Params
brokerVMName="$3"

#container Params
containerName="$4"
containerPort="${5:-"$(docker port "$containerName" | cut -d \: -f 2)"}"

hostVMIP=`(ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://')`

ssh "$xenAdmin"@"$deliveryControllerIP" 'powershell "C:\deleteXenContainer.ps1 '"$hostVMIP"' '"$containerPort"' '"$containerName"' '"$brokerVMName"'"'