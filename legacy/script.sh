#!/bin/bash

CONFIG_FILE="Untitled-1.coffee"
TARGET_SECTION="[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]"

# Проверяем, есть ли уже параметр "SystemdCgroup = true" в нужном блоке
if ! grep -q "SystemdCgroup = true" "$CONFIG_FILE"; then
  # Если строки нет, добавляем её в конец нужного блока
  sed -i "/$TARGET_SECTION/a \ \ \ SystemdCgroup = true" "$CONFIG_FILE"
  echo "Параметр 'SystemdCgroup = true' добавлен в конфигурацию."
else
  echo "Параметр 'SystemdCgroup = true' уже существует в конфигурации."
fi

# Перезапуск containerd для применения изменений
# sudo systemctl restart containerd
