Param(   
    [string]$hostVMIP,
    [string]$p,
    [string]$containerName,
    [string]$brokerVMName
)

function CheckIP([string]$ip) {
    if ([BOOL]($ip -as [IPADDRESS])) {
        Write-Host "is a valid address" 
    } else {
        write-Host -ForegroundColor Red "is an invalid address"
        exit
    }
}

#Check IPs
CheckIP $hostVMIP

#Add all Citrix-commands to Snapin
Add-PSSnapin Citrix.*.Admin.V*


#Logging
$logPath = "C:\logs\"
$logFileName = "CitrixDockerConnector_$(gc env:computername).log"

function LogWrite([string]$logString) {
    $date = Get-date
    if((Test-Path $logPath) -eq 0) {
        mkdir $logPath;
    }
    $logString = "$date :: $logString"
    $fullPath = $logPath + $logFileName
    Add-content  $fullPath -value $logString
    Write-Host $logString
}

$dc = Get-BrokerApplication -Name "Docker Container $containerName" -ErrorAction SilentlyContinue
if ($dc) { 
    LogWrite "Deleting Docker-App 'Docker Container $containerName'."
    Remove-BrokerApplication -InputObject $dc
    LogWrite "Successfully deleted Docker-App."
    LogWrite "Deleting .con Files..."
    Get-ChildItem \\$brokerVMName\C$\Users -recurse -Filter "$hostVMIP-$p*.con" | foreach ($_) {remove-item $_.fullname}
}
else {
    LogWrite "No Docker-App 'Docker Container $containerName' found."
}


#
# Log Errors
#
if($error[0]) { LogWrite ($error[0] | out-string) }