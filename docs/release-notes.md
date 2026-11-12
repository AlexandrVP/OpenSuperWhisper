# OpenSuperWhisper 0.1.3

**Редактируемые списки фраз теперь применяются к Whisper, Parakeet v2 и Parakeet v3.**

- Подключён существующий фильтр к обоим вариантам Parakeet при диктовке и обработке
  аудиофайлов. Используются те же правила для целых предложений и завершающих фраз.
- Переключатель **Filter Known Phrases** и кнопка **«Посмотреть фразы…»** доступны в
  **Settings → Transcription → Output Options** при выборе любого движка.
- Списки и переключатель общие для всех движков. Сохранённые пользовательские фразы
  и состояние фильтра сохраняются при обновлении; заново вводить списки не нужно.
- Обработка Whisper и его временные метки сохраняют прежнее поведение.

Фильтр сопоставляет готовый текст со списком: он может удалить намеренно
произнесённую фразу. Отключите его или измените список при диктовке такого материала.
Parakeet v2 по-прежнему распознаёт только английский. Старая история не переписывается.
Исправление первого запуска из 0.1.2 также включено.

### Проверки

Автоматические проверки фильтра и интеграции с обоими вариантами Parakeet выполняются
до упаковки приложения. Интеграционные проверки используют контролируемый текст
вместо настоящего ASR; распознавание реальными моделями Parakeet этим не проверяется.
Приложение собирается с настоящей закреплённой версией FluidAudio; ZIP проходит
проверку архитектуры, библиотек, ресурсов, подписи и распаковки.

### Установка и обновление

**Apple Silicon (M1 и новее), macOS 15 и новее.** Скачайте
`OpenSuperWhisper-0.1.3-macOS-arm64.zip` ниже, распакуйте и перенесите приложение
в «Программы». Перед заменой завершите предыдущую версию. Xcode и Homebrew для
установки не нужны; модели, настройки и историю удалять не нужно.

Сборка подписана ad hoc, без Developer ID и нотариализации Apple. Если macOS
блокирует первый запуск, выберите **«Готово» / «Отмена»**, затем
**Конфиденциальность и безопасность → Всё равно открыть** и подтвердите запуск.
**«Переместить в Корзину» удаляет приложение.**

Скачайте модель в начальной настройке, нажмите Continue и выдайте разрешения
микрофона и универсального доступа. Для правой Option также нужен мониторинг ввода.
При обновлении из-за смены локальной подписи может понадобиться удалить старую
запись OpenSuperWhisper из универсального доступа и мониторинга ввода, добавить
`/Applications/OpenSuperWhisper.app` заново и перезапустить приложение.

В ZIP есть `INSTALL.md`; [подробная инструкция](https://github.com/AlexandrVP/OpenSuperWhisper/blob/develop/docs/install.md).
Модели скачиваются отдельно. Intel Mac и Windows не поддерживаются.

### English

**0.1.3 applies the editable phrase lists to Whisper, Parakeet v2 and Parakeet v3.**
The shared **Filter Known Phrases** switch and phrase editor are available for either
engine under Settings → Transcription → Output Options. Existing custom lists and
the enabled/disabled preference are preserved. Both dictation and file transcription
are covered; existing history and Whisper timestamp behavior are unchanged.
Matching can remove intentionally spoken phrases. Parakeet v2 remains English-only.

Engine integration checks cover both Parakeet versions using a stub decoder;
they do not validate recognition by real models. The release compiles against the
real pinned FluidAudio SDK and includes the first-run setup fix from 0.1.2.

Download the arm64 ZIP, quit the old app, and move the new app to Applications.
Requires Apple Silicon and macOS 15+. Native libraries are bundled; models are not.
This release is ad-hoc signed and not Apple-notarized. A trusted download may need
Privacy & Security → Open Anyway. Grant Microphone, Accessibility and Input Monitoring
for modifier shortcuts; updates may require re-adding the app and restarting.
Keep your models and settings. See `INSTALL.md` in the ZIP.
