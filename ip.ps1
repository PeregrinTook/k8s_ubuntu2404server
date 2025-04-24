$adapterName = "Ethernet"
$ip = (Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" }).IPAddress
Write-Output $ip
