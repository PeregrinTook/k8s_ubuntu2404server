$adapterName = "Ethernet"

# Получаем IP-адрес и маску подсети
$adapterInfo = Get-NetIPAddress -InterfaceAlias $adapterName -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" }

# Извлекаем IP и маску подсети
$ip = $adapterInfo.IPAddress
$subnetMask = $adapterInfo.PrefixLength

Write-Output "IP-адрес: $ip"
Write-Output "Маска подсети: $subnetMask"

# arp -a
$macAddress = "8c-89-a5-0f-aa-19"

# Функция для проверки и пинга
function Test-ARPConnection {
    param (
        [string]$macAddress,
        [int]$maxAttempts = 10
    )

    $attemptCount = 0  # Счетчик попыток

    while ($attemptCount -lt $maxAttempts) {
        # Ищем запись с данным MAC-адресом в ARP-таблице
        $arpEntry = Get-NetNeighbor | Where-Object {$_.LinkLayerAddress -eq $macAddress}

        # Если запись найдена
        if ($arpEntry) {
            $ipForTesting = $arpEntry.IPAddress
            $state = $arpEntry.State

            Write-Output "Запись для MAC $macAddress найдена в состоянии $state. Тестирую сеть с IP $ipForTesting..."

            # Если состояние записи Reachable, выполняем пинг
            if ($state -eq 'Reachable') {
                $networkTest = Test-Connection -ComputerName $ipForTesting -Count 1 -Quiet

                if ($networkTest) {
                    Write-Output "Сеть с IP $ipForTesting доступна! Скрипт завершён."
                    return # Завершаем выполнение функции при успешном подключении
                } else {
                    Write-Output "Не удалось подключиться к IP $ipForTesting, несмотря на состояние Reachable. Повторяю пинг..."
                    # Выполняем Test-Connection для дальнейших попыток
                    Test-Connection -ComputerName $ipForTesting -Count 1
                }
            }
            else {
                # Если состояние записи не Reachable (например, Stale), выполняем Test-Connection и повторяем попытку
                Write-Output "Запись для MAC $macAddress не в состоянии Reachable. Пингуем IP $ipForTesting..."
                Test-Connection -ComputerName $ipForTesting -Count 1
            }
        } else {
            Write-Output "Запись для MAC $macAddress не найдена или была удалена из ARP-таблицы."
            return # Завершаем выполнение, если запись в ARP-таблице не найдена
        }

        # Увеличиваем счетчик попыток
        $attemptCount++
        # Пауза перед следующей попыткой
        Start-Sleep -Seconds 10
    }

    Write-Output "Максимальное количество попыток ($maxAttempts) достигнуто. Скрипт завершён."
}




# Запуск функции
Test-ARPConnection -macAddress $macAddress



# ping $ip_for_updating
# arp -a

# 100.66.72.97
# ping /?