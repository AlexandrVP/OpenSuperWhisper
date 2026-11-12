# Shared transcription phrase filter

`WhisperHallucinationFilter` is a small, opt-out text postprocessor shared by
Whisper and both Parakeet versions (v2/v3) since release 0.1.3. Settings >
Transcription > Output Options contains **Filter Known Phrases** for either engine
(named **Filter Known Whisper Phrases** before 0.1.3). The preference `filterWhisperHallucinations` defaults
to true in this patched source. **Посмотреть фразы…** opens two editable lists:
whole sentences anywhere, and closing sentences at the end of a recording. Use one
phrase per line. Save applies both lists to subsequent transcriptions and persists
them locally. Empty lists are supported. Cancel discards the draft, including a
pending restore of the defaults. The token `{И.Фамилия}` matches a Cyrillic initial
and surname, such as М. Лосева. The existing preference keys are retained, so
updating preserves custom lists and the enabled/disabled switch. The settings are
shared across engines, not separate per model. Parakeet v2 remains English-only.

The filter recognises a curated set of Russian/English subtitle credits as
complete sentences or lines, and a few common sign-offs only at the end of a
transcript. Matching is case-insensitive. It operates on joined decoder text,
then maps the deleted ranges back to their source segments before timestamp
formatting. Raw `DetailedTranscription.segments` remain available for diagnostics.
Parakeet v2 and v3 both use `FluidAudioEngine`, which filters `result.text` before
trimming and Asian autocorrection. The Whisper segment/timestamp path is unchanged.
File transcription and live dictation use the filter in their selected engine.

Ordinary replies, mentions inside longer sentences, and quoted examples are
preserved by the covered rules. This is a heuristic: a genuinely spoken
standalone credit or closing phrase can still match. Disable the option when
dictating such material. It does not detect every hallucination or listen to
the audio. The existing VAD and decoding thresholds are unchanged. Existing
recording history is not rewritten.

## Sources

- Russian observations by waveletdeboshir, collected with large-v2 on 13 hours
  of noise (a community list, not an official or exhaustive blacklist):
  https://gist.github.com/waveletdeboshir/8bf52f04bf78018194f25b2390c08309
- Reports of the DimaTorzok credit in Whisper:
  https://github.com/openai/whisper/discussions/2372
- Multilingual noise-only dataset (MIT); useful for research, but ordinary
  spoken phrases in it must not all be automatically deleted:
  https://huggingface.co/datasets/sachaarbonel/whisper-hallucinations
- Another detector documents the limitations of matching text without audio:
  https://github.com/tinyproof/whisper-cleanup

The regex rules are an independent implementation. No entire community list
or third-party detector is bundled or fetched at runtime.

## Validation without Xcode

From the repository root, with Apple's Swift command-line tools:

```sh
mkdir -p .filter-check/module-cache
swiftc -swift-version 5 -D FILTER_STANDALONE_TEST \
  -module-cache-path .filter-check/module-cache \
  OpenSuperWhisper/Utils/WhisperHallucinationFilter.swift \
  OpenSuperWhisperTests/WhisperHallucinationFilterTests.swift \
  -o .filter-check/filter-tests
.filter-check/filter-tests
```

The same scenarios are also available in the normal XCTest target. They cover
false positives, repeated tails, mixed credits and sign-offs, Unicode, disabling
the filter, and every character boundary between two decoder segments.

Building the complete app requires full Xcode and the repository's existing
native dependencies/submodules; see `run.sh` and `.github/workflows/build.yml`.
Command-line tools alone can validate the filter, not the complete app/UI.

## Parakeet integration checks

Run `bash Scripts/check-parakeet-filter.sh` with Apple's Swift command-line tools.
It compiles the production `FluidAudioEngine` and filter against a test-only
FluidAudio module that returns controlled decoder text. Both v2 and v3 paths are
checked for default/custom phrases, disabling, empty lists, ordinary speech and
autocorrection order. This verifies the engine integration without downloading
models; it does not measure recognition accuracy or run the real Core ML models.
The release build runs these checks and compiles against the pinned real FluidAudio SDK.
