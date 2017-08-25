$vboxmanage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$params = "controlvm", "work", "keyboardputscancode", "1c"

while ($true)
{
  & $vboxmanage $params
  $delay = Get-Random -Minimum 700 -Maximum 2000
  Start-Sleep $delay
}
