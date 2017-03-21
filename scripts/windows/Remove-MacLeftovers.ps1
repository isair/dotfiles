param ( [string]$Path )

Get-ChildItem -Recurse -Force $Path | Where-Object{$_.Name -Match "^\._.*"} | Remove-Item -Force
