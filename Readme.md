# OpenSuperWhisper — editable Whisper phrase filter

Fork of [Starmel/OpenSuperWhisper](https://github.com/Starmel/OpenSuperWhisper) with an editable filter for recurring Whisper phrases.

OpenSuperWhisper is a macOS application that provides real-time audio transcription using the Whisper model. It offers a seamless way to record and transcribe audio with customizable settings and keyboard shortcuts.

<p align="center">
<img src="docs/image.png" width="400" /> <img src="docs/image_indicator.png" width="400" />
</p>

## Features

- 🎙️ Real-time audio recording and transcription
- 🧠 Two transcription engines: [Whisper](https://github.com/ggerganov/whisper.cpp) and [Parakeet](https://github.com/AntinomyCollective/FluidAudio) — download models directly from the app
- ⌨️ Global keyboard shortcuts — key combination or single modifier key (e.g. Left ⌘, Right ⌥, Fn)
- 🖱️ Mouse button trigger — bind the middle or an extra (thumb) mouse button to start/stop recording
- ✊ Hold-to-record mode — hold the shortcut, modifier key or mouse button to record, release to stop
- 📁 Drag & drop audio files for transcription with queue processing
- 🎤 Microphone selection — switch between built-in, external, Bluetooth and iPhone (Apple Continuity) mics from the menu bar
- 🌍 Support for multiple languages with auto-detection
- 🇯🇵🇨🇳🇰🇷 Asian language autocorrect ([autocorrect](https://github.com/huacnlee/autocorrect))

## Installation

Download the **macOS arm64 ZIP** from [the latest release](https://github.com/AlexandrVP/OpenSuperWhisper/releases/latest), extract it and move `OpenSuperWhisper.app` to Applications. No Xcode or Homebrew is needed. The “Source code” archives are for developers.

**Requires Apple Silicon (M1 or newer) and macOS 15 or newer.** Intel Macs are not supported.

This fork's builds are ad-hoc signed and not notarized by Apple. On first launch a trusted download may need **System Settings → Privacy & Security → Open Anyway**. Grant Microphone, Accessibility and Input Monitoring, restart the app, select your microphone and download a model. Models are not bundled.

**[Инструкция по установке на русском / Installation guide](docs/install.md)**

The filter is under Settings → Transcription → Output Options → **Filter Known Whisper Phrases**. Use **«Посмотреть фразы…»** to edit the lists. See [filter behavior](docs/whisper_hallucination_filter.md).

`brew install opensuperwhisper` installs the upstream app; use this fork's release ZIP for the editable filter.

## Support

If you encounter any issues or have questions, please:
1. Check the existing issues in the repository
2. Create a new issue with detailed information about your problem
3. Include system information and logs when reporting bugs

## Building locally

Requires full Xcode 26.2 or newer and an Apple Silicon Mac. Open Xcode once to complete setup.

```sh
git clone --recurse-submodules https://github.com/AlexandrVP/OpenSuperWhisper.git
cd OpenSuperWhisper
brew install cmake libomp rust
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash Scripts/build-release.sh 0.1.1
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

You can download Whisper model files (`.bin`) from the [Whisper.cpp Hugging Face repository](https://huggingface.co/ggerganov/whisper.cpp/tree/main). Place the downloaded `.bin` files in the app's models directory. On first launch, the app will attempt to copy a default model automatically, but you can add more models manually.

### Hebrew (ivrit.ai)

For Hebrew transcription, download the **"Turbo V3 Hebrew"** model from Settings → Model. It is [ivrit.ai](https://www.ivrit.ai/)'s Hebrew fine-tune of `whisper-large-v3-turbo` ([whisper-large-v3-turbo-ggml](https://huggingface.co/ivrit-ai/whisper-large-v3-turbo-ggml)) — the same base model as the other "Turbo V3" entries, but tuned for Hebrew. Selecting it automatically sets the input language to Hebrew, which these models require to be set explicitly.
