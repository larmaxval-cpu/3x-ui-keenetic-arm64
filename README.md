# 3x-ui для Keenetic ARM64 / Entware

Адаптированная версия **3x-ui v3.11.0** для роутеров Keenetic с архитектурой ARM64 и установленным Entware.

## Установка

```sh
opkg update
opkg install bash curl unzip coreutils
curl -fsSL https://raw.githubusercontent.com/larmaxval-cpu/3x-ui-keenetic-arm64/main/install.sh -o /opt/tmp/install-3x-ui.sh
sh /opt/tmp/install-3x-ui.sh
```

**Внимание:** установщик предназначен для чистой установки. Полный цикл установки на новом устройстве пока не проверен. Не запускайте его поверх существующей панели.

## Скриншот

![Панель 3x-ui на Keenetic ARM64](images/dashboard.png)

## Исправления

- Корректное отображение свободного места на накопителе Keenetic.
- Исправленный перезапуск панели в среде Entware.

## Релиз

[3x-ui v3.11.0-keenetic.1](https://github.com/larmaxval-cpu/3x-ui-keenetic-arm64/releases/tag/v3.11.0-keenetic.1)

## Поддержать проект

Если проект оказался полезен, можно поддержать его развитие.

**Альфа-Банк:** `2200 1535 1418 2378`
