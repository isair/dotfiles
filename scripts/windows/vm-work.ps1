$vboxmanage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" 
$params = "controlvm", "work", "keyboardputscancode", "1c"

while ($true)
{
  & $vboxmanage $params
  $delay = Get-Random -Minimum 1 -Maximum 5
  Start-Sleep $delay
}
