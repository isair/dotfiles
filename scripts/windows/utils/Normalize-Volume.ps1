If(!(new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
    $newProcess.Arguments = $myInvocation.MyCommand.Definition
    $newProcess.Verb = "runas"
    $null = [System.Diagnostics.Process]::Start($newProcess)
    Return
}

cls
$ErrorActionPreference = "SilentlyContinue"

Write-Host '--- Reset Windows Audio Mixer ---' -ForegroundColor Cyan;""

Write-Host 'Stopping Service [Audiosrv]             : ' -ForegroundColor White -NoNewline
$Error.Clear()
Stop-Service -Name Audiosrv -Force
If($Error) {Write-Host 'Error' -ForegroundColor Red} Else {Write-Host 'OK' -ForegroundColor Green}

Write-Host 'Stopping Service [AudioEndpointBuilder] : ' -ForegroundColor White -NoNewline
$Error.Clear()
Stop-Service -Name AudioEndpointBuilder -Force
If($Error) {Write-Host 'Error' -ForegroundColor Red} Else {Write-Host 'OK' -ForegroundColor Green}

Write-Host 'Deleting Registry Key [PropertyStore]   : ' -ForegroundColor White -NoNewline
$Error.Clear()
Remove-Item -Path 'HKCU:Software\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\PropertyStore' -Force -Recurse
If($Error) {Write-Host 'Error' -ForegroundColor Red} Else {Write-Host 'OK' -ForegroundColor Green}

Write-Host 'Creating Registry Key [PropertyStore]   : ' -ForegroundColor White -NoNewline
$Error.Clear()
$null = New-Item -Path 'HKCU:Software\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\' -Name PropertyStore
If($Error) {Write-Host 'Error' -ForegroundColor Red} Else {Write-Host 'OK' -ForegroundColor Green}

Write-Host 'Starting Service [Audiosrv]             : ' -ForegroundColor White -NoNewline
$Error.Clear()
Start-Service -Name Audiosrv
If($Error) {Write-Host 'Error' -ForegroundColor Red} Else {Write-Host 'OK' -ForegroundColor Green}

Sleep -Seconds 5
