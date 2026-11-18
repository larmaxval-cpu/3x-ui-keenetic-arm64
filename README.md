# 3x-ui для Keenetic ARM64 / Entware

Адаптированная версия **3x-ui v3.11.0** для роутеров Keenetic с архитектурой **ARM64 (aarch64)** и установленным **Entware**.
Протестировано на Keenetic Ultra (KN-1811) EAEU

## Установка

Подключитесь к Keenetic по SSH и выполните:

```sh
opkg update
opkg install bash curl unzip coreutils
mkdir -p /opt/tmp
curl -fsSL https://raw.githubusercontent.com/larmaxval-cpu/3x-ui-keenetic-arm64/main/install.sh -o /opt/tmp/install-3x-ui.sh
sh /opt/tmp/install-3x-ui.sh
```

Установщик загружает исправленный бинарник из [релиза проекта](https://github.com/larmaxval-cpu/3x-ui-keenetic-arm64/releases/tag/v3.11.0-keenetic.1), проверяет его SHA256 и устанавливает необходимые компоненты. Перед использованием ознакомьтесь с [`install.sh`](install.sh).

## Скриншот

![Работающая панель 3x-ui на Keenetic ARM64](images/dashboard.png)

## Что исправлено

- Корректное отображение свободного места на накопителе Keenetic.
- Корректный перезапуск панели в среде Entware.

## Управление

После установки команда управления панелью:

```sh
x-ui
```

Автозапуск выполняется через `/opt/etc/init.d/S99x-ui`.

## Скачать релиз

**[3x-ui v3.11.0-keenetic.1](https://github.com/larmaxval-cpu/3x-ui-keenetic-arm64/releases/tag/v3.11.0-keenetic.1)**

Опубликован готовый бинарник `xui-linux-arm64` и файл контрольных сумм `SHA256SUMS`.

## Поддержать проект

Если проект оказался полезен, можно поддержать его развитие.

**Альфа-Банк:** `2200 1535 1418 2378`
