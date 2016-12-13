Param(
    [string]$hostVMIP,
    [string]$p,
    [string]$containerName,
    [string]$brokerVMName,
    [string]$desktopGroupName,
    [string]$machineCatalogName
)

function CheckIP([string]$ip) {
    if ([BOOL]($ip -as [IPADDRESS])) {
        Write-Host "is a valid address" 
    } else {
        write-Host -ForegroundColor Red "is an invalid address"
        exit
    }
}

#Check IP
CheckIP $hostVMIP

#Add all Citrix-commands to Snapin
Add-PSSnapin Citrix.*.Admin.V*

#Let all errors terminate the script
$erroractionPreference="stop"

#Logging
$logPath = "C:\logs\"
$logFileName = "CitrixDockerConnector_$(gc env:computername).log"

$machineCatalog
$desktopGroup
$brokerVM


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

LogWrite "Initialise Docker-Integration"

#
# Check for Machine Catalog
#

try {
    $machineCatalog = Get-BrokerCatalog -Name $machineCatalogName
    if ($machineCatalog) { LogWrite "Using existing Machine-Catalog '$machineCatalogName'" }
}
catch [Citrix.Broker.Admin.SDK.SdkOperationException]{
    LogWrite "Machine Catalog '$machineCatalogName' not found. Creating it..."
    $machineCatalog = New-BrokerCatalog -AllocationType Random -IsRemotePC $false -MachinesArePhysical $true -Name $machineCatalogName `
    -PersistUserChanges OnLocal -ProvisioningType Manual -Scope @() -SessionSupport MultiSession
    Logwrite "Machine Catalog created"
}

#
# Check for Delivery Group
#

try {
    $desktopGroup = Get-BrokerdesktopGroup -Name $desktopGroupName
    if ($desktopGroup) { LogWrite "Using existing Delivery Group '$desktopGroupName'" }
}
catch [Citrix.Broker.Admin.SDK.SdkOperationException]{
    LogWrite "desktopGroup not existing yet. Created Desktop Group '$desktopGroupName'"
    $desktopGroup = New-BrokerdesktopGroup $desktopGroupName -ColorDepth TwentyFourBit -DeliveryType DesktopsAndApps -DesktopKind Shared `
        -InMaintenanceMode $false -IsRemotePC $false -OffPeakBufferSizePercent 10 -PeakBufferSizePercent 10 -PublishedName $desktopGroupName `
        -Scope @() -SecureIcaRequired $false -SessionSupport MultiSession -ShutdownDesktopsAfterUse $false
    LogWrite "Successfully created Delivery Group"
}

#
# Check Broker-VM
#

try {
    $brokerVM = Get-BrokerMachine "$env:USERDOMAIN\$brokerVMName"
    if ($brokerVM) { LogWrite "Broker-VM found" }
}
catch [Citrix.Broker.Admin.SDK.SdkOperationException]{
    LogWrite "Host-VM not found for DNS-Name '$env:USERDOMAIN\$brokerVMName'. Creating Host-Machine to use services"
    $hostVM = New-BrokerMachine "$env:USERDOMAIN\$brokerVMName" -CatalogUid $machineCatalog.Uid  
    LogWrite "Successfully created Host-VM"  
}

#
# Check if machine is part of Delivery Group
#

try {
    $dgm = Get-BrokerMachine -desktopGroupUid $desktopGroup.Uid -MachineName "$env:USERDOMAIN\$brokerVMName"
    if ($dgm) { LogWrite "Machine is part of Delivery Group" }
}
catch [Citrix.Broker.Admin.SDK.SdkOperationException]{
    #Add Machine to Delivery Group
    LogWrite "Machine is not part of Delivery Group yet. Pushing machine to Delivery Group for usage..."
    Add-BrokerMachine -InputObject $brokerVM -desktopGroup $desktopGroup
    LogWrite "Successfully pushed machine to Delivery Group"
}

#
# Check if Docker-hostVM is integrated
#

try {    
    $uniqueID = $hostVMIP -replace '\.','-'
    $hvm = Get-BrokerApplication -Name "Docker Host-VM $uniqueID" 
    if ($hvm) { LogWrite "Docker Host-VM found" }
}
catch [Citrix.Broker.Admin.SDK.SdkOperationException]{
    #Add Machine to Delivery Group
    LogWrite "Docker Host-VM is not created yet. Creating XenApp Application..."
    # Create Application 'Docker Container'
    New-BrokerApplication  -ApplicationType "HostedOnDesktop" -CommandLineArguments "/c call %homedrive%\connectToContainer.bat $hostVMIP 22" `
        -CommandLineExecutable "%SystemRoot%\System32\cmd.exe" -CpuPriorityLevel "Normal" -desktopGroup $desktopGroup -Enabled $True `
        -IconUid 11 -MaxPerUserInstances 0 -MaxTotalInstances 0 -Name "Docker Host-VM $uniqueID" `
        -Priority 0 -PublishedName "Docker Host-VM $uniqueID" -SecureCmdLineArgumentsEnabled $True -ShortcutAddedToDesktop $False `
        -ShortcutAddedToStartMenu $False -UserFilterEnabled $False -Visible $True -WaitForPrinterCreation $False -WorkingDirectory "%SystemRoot%\System32"
    LogWrite "Successfully created Docker Host-VM Application."
}


# 
# Create Application 'Docker Container'
# 

LogWrite "Creating Docker-XenApp Application..."
New-BrokerApplication  -ApplicationType "HostedOnDesktop" -CommandLineArguments "/c call %homedrive%\connectToContainer.bat $hostVMIP $p" `
    -CommandLineExecutable "%SystemRoot%\System32\cmd.exe" -CpuPriorityLevel "Normal" -desktopGroup $desktopGroup -Enabled $True `
    -IconUid 10 -MaxPerUserInstances 0 -MaxTotalInstances 0 -Name "Docker Container $containerName" `
    -Priority 0 -PublishedName "Docker Container $containerName" -SecureCmdLineArgumentsEnabled $True -ShortcutAddedToDesktop $False `
    -ShortcutAddedToStartMenu $False -UserFilterEnabled $False -Visible $True -WaitForPrinterCreation $False -WorkingDirectory "%SystemRoot%\System32"
LogWrite "Successfully created Docker Container Application."


#
# Log Errors
#
if($error[0]) { LogWrite ($error[0] | out-string) }
