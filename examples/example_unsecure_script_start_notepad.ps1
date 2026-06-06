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
$SACDisablerService = (Get-Service -Name SAC-Disabler -ErrorAction Ignore)
$appWorkingFolder = $PSScriptRoot
$appPath = "notepad.exe"

if (-not $SACDisablerService) {
	Write-Error "No SAC-Disabler service installed! Please install it!"
	exit 1
}

if ($SACDisablerService.Status -ne 'Running') {
	Write-Output "Starting Smart App Control Disabler Service..."
	Start-Service $SACDisablerService
    # Verify started service
    if ($SACDisablerService.Status -ne 'Running') {
        Write-Error "Failed to start Smart App Control"
        exit 1
    }
	Write-Output "Started Smart App Control Disabler Service."
} else {
	Write-Output "Smart App Control Disabler Service is already started!"
}

Write-Output "my cool unsafe app"
cd $appWorkingFolder
Start-Process $appPath
Start-Sleep -Milliseconds 3000