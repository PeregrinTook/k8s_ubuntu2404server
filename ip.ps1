$adapterName = "Ethernet"

# Получаем IP-адрес и маску подсети
$adapterInfo = Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" }

# Извлекаем IP и маску подсети
$ip = $adapterInfo.IPAddress
$subnetMask = $adapterInfo.PrefixLength

Write-Output "IP-адрес: $ip"
Write-Output "Маска подсети: $subnetMask"

# arp -a
$ip_for_updating = Get-NetNeighbor | Where-Object {$_.LinkLayerAddress -eq "8c-89-a5-0f-aa-19"} | Select-Object -ExpandProperty IPAddress

if ($ip_for_updating) {
    Write-Output "Запись для IP найдена:"
    # Write-Output $ip_for_updating
    Test-Connection -ComputerName $ip_for_updating -Count 1
} else {
    Write-Output "Запись для IP $ip_for_updating не найдена или пуста."
}

# ping $ip_for_updating
# arp -a

# 100.66.72.97