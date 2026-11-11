Готовая версия форка AlexandrVP с фильтром повторяющихся фраз Whisper.

- Фильтр субтитров и типичных завершающих фраз с переключателем в настройках.
- Редактирование списка фраз прямо в приложении, сохранение своего списка.
- Автоматическая сборка Release для Apple Silicon с базовыми инструкциями M1.
- ZIP включает библиотеки; устанавливать Xcode или Homebrew не требуется.

### Установка

**Apple Silicon (M1 и новее), macOS 15 и новее.** Скачайте
`OpenSuperWhisper-<версия>-macOS-arm64.zip` ниже, распакуйте и перенесите приложение
в «Программы». Архивы “Source code” для установки не нужны.

Сборка подписана ad hoc и не нотариализована Apple: при первом запуске может
потребоваться **Конфиденциальность и безопасность → Всё равно открыть**.
Выдайте разрешения микрофона, универсального доступа и мониторинга ввода,
перезапустите приложение, выберите микрофон и скачайте модель.

В ZIP есть инструкция `INSTALL.md`; [инструкция на GitHub](https://github.com/AlexandrVP/OpenSuperWhisper/blob/develop/docs/install.md).
Модели скачиваются отдельно. При обновлении macOS может попросить заново выдать
разрешения из-за смены локальной подписи. Intel Macs не поддерживаются.

### English

Download the arm64 ZIP, extract it and move the app to Applications. Requires
Apple Silicon and macOS 15+. All native libraries are bundled; models are
downloaded in the app. This release includes the editable Whisper phrase filter.
The app is ad-hoc signed, not Apple-notarized. A trusted download may need
Privacy & Security → Open Anyway. Grant Microphone, Accessibility and Input
Monitoring, then restart. See `INSTALL.md` in the ZIP for setup and updates.
