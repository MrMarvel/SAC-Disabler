##CODE OWNERSHIP#############################################################
# Author: Sergey K. (MrMarvel)
# Date: 06.06.2026
##CODE OWNERSHIP###FEEL FREE TO USE ANYWHERE#################################

#at top of script
if (!
    #current role
    (New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    #is admin?
    )).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
) {
    #elevate script and exit current non-elevated runtime
    Start-Process `
        -FilePath 'powershell' `
        -ArgumentList (
            #flatten to single array
            '-File', "`"$($MyInvocation.MyCommand.Source)`"", $args `
            | %{ $_ }
        ) `
        -Verb RunAs
    exit
}
$appWorkingFolder = $PSScriptRoot
cd $appWorkingFolder
$serviceName = "SAC-Disabler"
$service = (Get-Service -Name SAC-Disabler -ErrorAction Ignore)
if ($service) {
	Write-Output "Found existing service. Removing..."
	./nssm remove $serviceName confirm
	Write-Output "Removed service `"$serviceName`""
}
Write-Output "Creating Service with name `"$serviceName`""
./nssm install $serviceName powershell.exe "-ExecutionPolicy Bypass -NoProfile -NonInteractive -WindowStyle Hidden -File SAC_service.ps1"
./nssm set $serviceName AppDirectory $appWorkingFolder
./nssm set $serviceName DisplayName "SAC Disabler Service"
./nssm set $serviceName Description "Smart App Control Temporarly Disabler Service"
./nssm set $serviceName AppRestartDelay 1000
# ./nssm set $serviceName AppExit Stop # Broken (instead manually)
$regeditPath = "HKLM:\SYSTEM\ControlSet001\Services\SAC-Disabler\Parameters\AppExit"
$regeditKey = "(default)"
$regeditValue = ((Get-ItemProperty -Path $regeditPath -Name $regeditKey -ErrorAction Ignore).$regeditKey)
if (-not $regeditValue) {
	Write-Error "Error creating: not found regedit key `"$regeditPath\{$regeditKey}`""
	Start-Sleep 10000
	exit 1
}
Set-ItemProperty -Path $regeditPath -Name $regeditKey -Value "Exit"
Write-Output "Service successfully created"
Start-Sleep -Milliseconds 5000