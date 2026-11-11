# Установка OpenSuperWhisper / Installation

Эта сборка форка AlexandrVP включает фильтр повторяющихся фраз Whisper и редактор
списка фраз. Требуется **Mac с Apple Silicon (M1 или новее), macOS 15 или новее**.
Intel и Windows не поддерживаются. Xcode, Homebrew и Git для установки не нужны.

1. Скачайте `OpenSuperWhisper-<версия>-macOS-arm64.zip` из
   [последнего релиза](https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest).
   Архивы **Source code** содержат исходники, а не готовое приложение.
2. Распакуйте ZIP. Перенесите `OpenSuperWhisper.app` в **Программы / Applications**.
   Если заменяете старую версию, сначала завершите её через меню приложения.
3. Запустите приложение. Эта сборка имеет локальную подпись (ad hoc), без Apple
   Developer ID и нотариализации. Если macOS не может проверить разработчика,
   после первой попытки запуска откройте **Системные настройки → Конфиденциальность
   и безопасность → Всё равно открыть**. Используйте это только для скачанной
   вами сборки, которой доверяете. [Инструкция Apple](https://support.apple.com/102445).
4. Разрешите **Микрофон** и **Универсальный доступ**. Для глобальной клавиши вроде
   правой Option также включите **Мониторинг ввода** для приложения. Перезапустите
   приложение после выдачи разрешений.
5. В приложении выберите микрофон и скачайте модель. Для русского языка подойдёт
   **Whisper V3 Large**; модель скачивается отдельно, в ZIP её нет.
6. Выберите клавишу записи. При включённом **Hold to Record** удерживайте её во
   время речи, затем отпустите. Сначала можно проверить запись кнопкой приложения.
7. Фильтр находится в **Settings → Transcription → Output Options → Filter Known
   Whisper Phrases**. Кнопка **«Посмотреть фразы…»** открывает редактируемые списки.

## Обновление и разрешения

При смене локально подписанной сборки macOS может привязать разрешения к старой
подписи. Если клавиша не работает, удалите старую запись OpenSuperWhisper из
«Универсального доступа» и «Мониторинга ввода», добавьте приложение из `/Applications`
заново и перезапустите его. Проверьте разрешение микрофона и выбранное устройство.
Удалять модели, историю и настройки для обновления не требуется.

Контрольная сумма находится в соседнем файле `.zip.sha256`. Для проверки положите
оба файла в одну папку и выполните `shasum -a 256 -c <имя-архива>.zip.sha256`.

## English

Requires **Apple Silicon (M1 or later), macOS 15 or later**. Download the release
ZIP (not “Source code”), extract it, and move the app into Applications. Quit the
old app before replacing it. No Xcode, Homebrew or Git is needed to run the app.

This build is ad-hoc signed and is not notarized by Apple. For a trusted download,
use System Settings → Privacy & Security → Open Anyway after the first launch
attempt if macOS cannot verify the developer. Grant Microphone and Accessibility;
also grant Input Monitoring for single-modifier shortcuts. Restart the app.
Choose your microphone, download a model, and configure the recording shortcut.
Models are not included in the archive. The editable phrase filter is under
Settings → Transcription → Output Options.

After an update, macOS may require removing and re-adding the app in Accessibility
and Input Monitoring because the ad-hoc signature changes. Keep your models and
settings. Intel Macs and Windows are not supported.
