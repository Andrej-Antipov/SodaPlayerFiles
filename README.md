# SodaPlayerFiles

A lightweight native macOS utility that automates opening the Soda Player torrent data folder.

[Версия на русском языке ниже](#русская-версия)

## ✨ Features

* **Instant Action:** Instantly opens `$TMPDIR/sodaplayer/data/torrent` in Finder and completely unloads itself from RAM.
* **Zero UI Overhead:** No Terminal window or Dock icons are displayed during execution.
* **Smart Alerts:** Displays a native, system-styled macOS error dialog if the folder does not exist (supports EN/RU locales).
* **Auto-Close:** The error dialog automatically disappears and terminates the application after 4 seconds.
* * **FocusMode** Error dialog: mute sound for Don't Disturb Mode .

## 📦 Installation

1. Go to the **Releases** section on the right and download the `SodaPlayerFiles.app.zip` archive.
2. Unpack the ZIP archive and move `SodaPlayerFiles.app` to your **Applications** folder.

> ⚠️ **Note:** On the first launch, if macOS security blocks the app (Gatekeeper), right-click the application icon and choose **Open**, then click **Open** again to grant execution permission.

## 🛠 Requirements

* **macOS:** 14.0 or newer.
* **Platform:** Apple Silicon (M1/M2/M3/M4) & Intel.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

# Русская Версия

Легковесная нативная утилита для macOS, которая автоматически открывает папку с кэшем торрентов Soda Player.

## ✨ Особенности

* **Мгновенная работа:** Открывает путь `$TMPDIR/sodaplayer/data/torrent` в Finder и сразу полностью выгружается из оперативной памяти.
* **Без лишнего UI:** При запуске не открываются окна Терминала или иконки в панели Dock.
* **Умные уведомления:** Если папки не существует, выводится аккуратное системное окно ошибки на языке вашей ОС (Русский/Английский).
* **Автозакрытие:** Окно ошибки самостоятельно исчезает и закрывает программу ровно через 4 секунды.
* **FocusMode** Сообщение об ошибке становится беззвучным если включен режим DND (сон или не беспокоить).

## 📦 Установка

1. Перейдите в раздел **Releases** справа и скачайте архив `SodaPlayerFiles.app.zip`.
2. Распакуйте архив и перетащите приложение в папку **Программы** (`Applications`).

> ⚠️ **Важно:** При первом запуске macOS может заблокировать программу (защита Gatekeeper). Чтобы разрешить запуск, нажмите на иконку приложения правой кнопкой мыши, выберите **Открыть**, а затем во всплывающем окне подтвердите действие, снова нажав **Открыть**.

## 🛠 Требования

* **macOS:** 14.0 или новее.
* **Архитектура:** Apple Silicon (M1/M2/M3/M4) & Intel.

## 📄 Лицензия

Этот проект распространяется под лицензией MIT - подробности см. в файле [LICENSE](LICENSE).
