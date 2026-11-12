# OpenSuperWhisper — фильтр фраз для Whisper и Parakeet

Форк [Starmel/OpenSuperWhisper](https://github.com/Starmel/OpenSuperWhisper) от
[AlexandrVP](https://github.com/AlexandrVP/OpenSuperWhisper): голосовой ввод для macOS
с общим фильтром фраз для Whisper, Parakeet v2 и v3 и редактором списка прямо в приложении.

**[Скачать готовое приложение](https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest)**
· [Подробная инструкция / Installation guide](docs/install.md)
· [Как работает фильтр](docs/whisper_hallucination_filter.md)
· [English quick start](#english-quick-start)

> **Перед установкой:** нужен Mac с Apple Silicon и macOS 15+. Сборка подписана
> локально (ad hoc), без Developer ID и нотариализации Apple. Первый запуск требует
> подтверждения macOS, выдачи разрешений и отдельной загрузки модели. После обновлений
> разрешения иногда приходится выдавать заново; подробности ниже.

## Чем этот форк отличается от оригинала

- **Общий фильтр фраз для Whisper и Parakeet v2/v3 (с 0.1.3).** Удаляет совпадения со списком типичных
  субтитров и завершающих фраз, например «Субтитры создавал Дима Торзок» и
  «Продолжение следует». Включён по умолчанию, его можно отключить в настройках.
- **Редактор фраз в приложении.** Кнопка **«Посмотреть фразы…»** открывает два списка:
  целые фразы в любом месте записи и фразы только в её конце. Можно добавлять,
  изменять и удалять строки, сохранять свой список и возвращать значения по умолчанию.
  Изменения сохраняются локально и применяются к следующим транскрипциям.
  Существующие списки и состояние переключателя сохраняются при обновлении; они общие
  для всех трёх движков. Parakeet v2 по-прежнему распознаёт только английский язык.
- **Исправленный первый запуск в 0.1.2.** После скачивания и выбора модели кнопка
  **Continue** загружает её без перезапуска приложения. Устранена ошибка
  **Model could not be loaded**, возникавшая из-за инициализации до выбора модели.
- **Готовые ZIP-релизы и автоматическая сборка.** GitHub Actions собирает приложение,
  проверяет фильтр и состав пакета, публикует ZIP и контрольную сумму SHA-256 для
  версионных тегов. Нужные библиотеки входят в ZIP; Xcode, Homebrew и Git пользователю
  не нужны. Модели скачиваются отдельно.

Фильтр находится в **Settings → Transcription → Output Options → Filter Known
Phrases** (до 0.1.3 — **Filter Known Whisper Phrases**). Переключатель и редактор
доступны при выборе Whisper и Parakeet. Фильтр работает при диктовке и обработке
аудиофайлов; уже сохранённую историю не меняет. Это сопоставление текста
со списком, поэтому фильтр не обнаруживает все галлюцинации и может удалить реально
произнесённую фразу из списка. При намеренной диктовке таких фраз отключите фильтр
или отредактируйте список. [Правила, ограничения и источники](docs/whisper_hallucination_filter.md).

## Установка готового приложения

### Требования

- **Apple Silicon: M1 или новее; macOS 15 или новее.** Готовый релиз не поддерживает
  Intel Mac и Windows.
- Интернет для скачивания приложения и модели. **Whisper V3 Large** в этой версии
  использует `large-v3-turbo` и занимает примерно **1,6 ГБ**; модель не входит в ZIP.
- На управляемом рабочем Mac разрешение запуска и доступ к устройствам могут
  ограничиваться настройками организации.

### Первый запуск

1. Откройте [последний релиз](https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest)
   и скачайте **`OpenSuperWhisper-<версия>-macOS-arm64.zip`**. Архивы **Source code**
   содержат исходники, а не готовое приложение. Команда `brew install opensuperwhisper`
   устанавливает оригинальный проект, а не этот форк с редактором фраз.
2. Распакуйте ZIP и перенесите **OpenSuperWhisper.app** в **Программы / Applications**.
3. Запустите приложение. Если macOS сообщает, что Apple не удалось проверить файл,
   выберите **«Готово»** или **«Отмена»**, чтобы оставить приложение на месте.
   **«Переместить в Корзину» удаляет приложение из «Программ».** Затем откройте
   **Системные настройки → Конфиденциальность и безопасность → Всё равно открыть**
   и подтвердите запуск в следующем окне. При необходимости используйте Touch ID
   или пароль Mac. Делайте это только для сборки, источнику которой доверяете.
   [Инструкция Apple](https://support.apple.com/102445).
4. На начальном экране выберите язык, клавишу записи и скачайте модель. Для русского
   языка можно выбрать **Whisper V3 Large**. Дождитесь окончания загрузки и нажмите
   **Continue**. Перезапуск для применения выбранной модели в 0.1.2 не нужен.
5. Выдайте приложению доступ к **Микрофону** и **Универсальному доступу**. Для глобальной
   клавиши вроде правой **Option** также включите **Мониторинг ввода**. В системных
   настройках выбирайте приложение именно из `/Applications/OpenSuperWhisper.app`.
   Если macOS предлагает перезапуск после выдачи разрешения, согласитесь.
6. Проверьте выбранный микрофон. При включённом **Hold to Record** поставьте курсор
   в текстовое поле, удерживайте выбранную клавишу во время речи и отпустите её.
   Для автоматической вставки включите **Settings → Transcription → Auto-paste
   Transcription**. Ожидаемый результат — индикатор записи, затем текст в поле.

В архиве также есть `INSTALL.md`. Подробности и проверка SHA-256 — в
[инструкции по установке](docs/install.md).

### Обновления и разрешения macOS

Перед заменой приложения завершите его через **OpenSuperWhisper → Quit** и перенесите
новую версию в «Программы». **Модели, историю и настройки удалять не нужно.**

У текущих сборок меняется локальная подпись. macOS может продолжать показывать
включённый переключатель для старой сборки, хотя новая сборка доступа не получает.
Если после обновления не работает клавиша или приложение просит разрешение снова:

1. В **Конфиденциальность и безопасность → Универсальный доступ** удалите старую
   запись **OpenSuperWhisper** кнопкой «−», затем через «+» добавьте
   `/Applications/OpenSuperWhisper.app` и включите доступ.
2. Для правой Option повторите это в **Мониторинге ввода**, затем перезапустите приложение.
3. Проверьте разрешение **Микрофона** и выбранное устройство записи. Если появится
   новый системный запрос, подтвердите его.

Удаление старых записей — возможный шаг при обновлении, а не обязательная часть
первой установки. Эти неудобства с локальной подписью пока сохраняются.
Для более удобного распространения нужны **Developer ID и нотариализация Apple**;
в текущем релизе их нет. Они позволят проходить стандартную проверку Gatekeeper,
но разрешения на микрофон и управление компьютером всё равно нужны.
[О подписи и нотариализации](https://developer.apple.com/developer-id/).

### Что проверено

**12 ноября 2026 года** релиз **0.1.2 (1008)** из публичного ZIP проверен на
**Mac с Apple M3 Pro, macOS 26.5**. Проверены установка скачанного архива, запуск через
«Всё равно открыть», скачивание Large и переход Continue с чистым профилем приложения,
диктовка правой Option, автоматическая вставка текста и доступность редактора фраз.

Это проверка на одном Mac. Она не гарантирует отсутствие проблем на всех поддерживаемых
моделях, версиях macOS или компьютерах с политиками организации.

## English quick start

This fork adds an editable, opt-out phrase filter shared by **Whisper, Parakeet v2
and Parakeet v3 since 0.1.3**, fixes loading the selected model on first-run Continue
in 0.1.2, and provides automatically built release ZIPs. The filter applies to new
dictation and audio-file transcriptions; existing history is unchanged. Your saved
lists and enabled/disabled preference survive the update and apply to all engines.
Parakeet v2 remains English-only. Find **Filter Known Phrases** and **«Посмотреть
фразы…»** under Settings → Transcription → Output Options with either engine selected.
Matching text can include an intentionally spoken phrase; edit the lists or disable
the filter when needed.

Download the **arm64 ZIP** from [the latest release](https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest),
extract it and move the app to Applications. Requires **Apple Silicon and macOS 15+**;
Intel and Windows are not supported. No Xcode, Homebrew or Git is needed. Models are
downloaded separately; Whisper V3 Large is `large-v3-turbo`, approximately 1.6 GB.
Homebrew's `opensuperwhisper` installs the upstream app, not this fork.

The release is **ad-hoc signed, without Developer ID or Apple notarization**. For a
trusted download blocked by macOS, choose **Done/Cancel**, then **System Settings →
Privacy & Security → Open Anyway** and confirm. **Move to Trash removes the app.**
Download a model in onboarding and click Continue. Grant Microphone and Accessibility;
also grant Input Monitoring for single-modifier shortcuts such as Right Option.
Restart if macOS requests it, select your microphone and test dictation into a text field.

After updates, the changed ad-hoc signature may require removing and re-adding
`/Applications/OpenSuperWhisper.app` in Accessibility and Input Monitoring, then
restarting. Keep your models, history and settings. Release 0.1.2 was tested on one
M3 Pro Mac running macOS 26.5; behavior on every supported configuration is not verified.
See the [installation guide](docs/install.md) and [filter documentation](docs/whisper_hallucination_filter.md).

## Core features inherited from OpenSuperWhisper

<p align="center">
<img src="docs/image.png" width="400" /> <img src="docs/image_indicator.png" width="400" />
</p>

- 🎙️ Real-time audio recording and transcription
- 🧠 Two transcription engines: [Whisper](https://github.com/ggerganov/whisper.cpp) and [Parakeet](https://github.com/AntinomyCollective/FluidAudio) — download models directly from the app
- ⌨️ Global keyboard shortcuts — key combination or single modifier key (e.g. Left ⌘, Right ⌥, Fn)
- 🖱️ Mouse button trigger — bind the middle or an extra (thumb) mouse button to start/stop recording
- ✊ Hold-to-record mode — hold the shortcut, modifier key or mouse button to record, release to stop
- 📁 Drag & drop audio files for transcription with queue processing
- 🎤 Microphone selection — switch between built-in, external, Bluetooth and iPhone (Apple Continuity) mics from the menu bar
- 🌍 Support for multiple languages with auto-detection
- 🇯🇵🇨🇳🇰🇷 Asian language autocorrect ([autocorrect](https://github.com/huacnlee/autocorrect))

## Support

If you encounter any issues or have questions, please:

1. Check the existing issues in the repository
2. Create a new issue with detailed information about your problem
3. Include system information and logs when reporting bugs

## Building locally

Requires full Xcode 26.2 or newer and Rust targeting `aarch64-apple-darwin`. Open Xcode once to complete setup. Intel Macs can cross-compile the ARM64 app; running it requires Apple Silicon.

```sh
git clone --recurse-submodules https://github.com/AlexandrVP/OpenSuperWhisper.git
cd OpenSuperWhisper
brew install cmake libomp rust
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash Scripts/build-release.sh 0.1.3
```

The ZIP and SHA-256 checksum are written to `dist/`. GitHub Actions builds the same ZIP for branch pushes and pull requests; pushing a `vMAJOR.MINOR.PATCH` tag publishes a release after successful checks. See [release maintenance](docs/release_build.md).

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

### Contribution TODO list

- [ ] Streaming transcription
- [ ] Custom dictionary / keyword boosting ([#19](https://github.com/Starmel/OpenSuperWhisper/issues/19))
- [ ] Intel macOS compatibility ([#15](https://github.com/Starmel/OpenSuperWhisper/issues/15))
- [ ] Agent mode ([#14](https://github.com/Starmel/OpenSuperWhisper/issues/14))
- [x] Background app ([#8](https://github.com/Starmel/OpenSuperWhisper/issues/8))
- [x] Support long-press single key audio recording ([#18](https://github.com/Starmel/OpenSuperWhisper/issues/18))

## License

OpenSuperWhisper is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Whisper Models

You can download Whisper model files (`.bin`) from the [Whisper.cpp Hugging Face repository](https://huggingface.co/ggerganov/whisper.cpp/tree/main). Release ZIPs do not include models. Download a model from the app on first launch, or place a compatible `.bin` file in the models directory shown under Settings → Model.

### Hebrew (ivrit.ai)

For Hebrew transcription, download the **"Turbo V3 Hebrew"** model from Settings → Model. It is [ivrit.ai](https://www.ivrit.ai/)'s Hebrew fine-tune of `whisper-large-v3-turbo` ([whisper-large-v3-turbo-ggml](https://huggingface.co/ivrit-ai/whisper-large-v3-turbo-ggml)) — the same base model as the other "Turbo V3" entries, but tuned for Hebrew. Selecting it automatically sets the input language to Hebrew, which these models require to be set explicitly.
