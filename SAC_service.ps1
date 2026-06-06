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
            '-File', $MyInvocation.MyCommand.Source, $args `
            | %{ $_ }
        ) `
        -Verb RunAs
    exit
}
#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Y'arg Matey, we're off to 64-bit land....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}

$wasEnabledSmartAppControl = (Get-MpComputerStatus).SmartAppControlState -eq "On"

if ($wasEnabledSmartAppControl) {
	Write-Output "Disabling Smart App Control..."
    # Disable: set to 0 (Off)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0
    echo "STOP" | citool -r | Out-Null  # Apply changes without reboot [web:18]

    # Verify disabled
    if ((Get-MpComputerStatus).SmartAppControlState -ne "Off") {
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 1
		echo "STOP" | citool -r | Out-Null
        Write-Error "Failed to disable Smart App Control"
        exit 1
    }
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 1
	Write-Output "Disabled Smart App Control."
}

Write-Output "my cool unsafe app"
Start-Sleep -Milliseconds 10000

if ($wasEnabledSmartAppControl) {
	Write-Output "Re-enabling Smart App Control..."
    # Re-enable: set to 1 (On)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 1
    # Verify re-enabled
	for ($i = 0; $i -lt 30; $i++) {
		echo "STOP" | citool -r | Out-Null  # Apply changes [web:18]
        if ((Get-MpComputerStatus).SmartAppControlState -eq "On") {
            break
        }
        Start-Sleep -Milliseconds 100
    }
    if ((Get-MpComputerStatus).SmartAppControlState -ne "On") {
        Write-Error "Failed to re-enable Smart App Control"
    }
	Write-Output "Successfully re-enabled Smart App Control"
}
Start-Sleep -Milliseconds 5000