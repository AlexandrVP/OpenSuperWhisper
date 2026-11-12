import Foundation

private struct Scenario {
    let name: String
    let input: String
    let expected: String
    var enabled = true
    var phrases = WhisperPhraseList.standard
    var autocorrect = false
}

@main
private enum ParakeetFilterChecks {
    static func main() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ParakeetFilterChecks-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let custom = WhisperPhraseList(sentences: ["Sponsor message"], endings: ["End of dictation", "C++ [test]"])
        let cases: [Scenario] = [
            .init(name: "default ending", input: "🙂 Send the report. Thanks for watching!", expected: "🙂 Send the report."),
            .init(name: "credit in middle", input: "First. Subtitles by the Amara.org community. Second.", expected: "First. Second."),
            .init(name: "only filtered text", input: "Thanks for watching!", expected: ""),
            .init(name: "repeated endings", input: "Ready. Thank you for watching. Please subscribe!", expected: "Ready."),
            .init(name: "ordinary speech", input: "  Thank you. Send the report!\n", expected: "Thank you. Send the report!"),
            .init(name: "quoted ending", input: "She said: “Thanks for watching!”", expected: "She said: “Thanks for watching!”"),
            .init(name: "longer sentence", input: "Thanks for watching the children.", expected: "Thanks for watching the children."),
            .init(name: "ending inside body", input: "Thanks for watching. Next topic.", expected: "Thanks for watching. Next topic."),
            .init(name: "custom ending", input: "Ready. End of dictation.", expected: "Ready.", phrases: custom),
            .init(name: "custom sentence", input: "Sponsor message. Ready.", expected: "Ready.", phrases: custom),
            .init(name: "custom literal punctuation", input: "Ready. C++ [test]!", expected: "Ready.", phrases: custom),
            .init(name: "custom replaces defaults", input: "Ready. Thanks for watching.", expected: "Ready. Thanks for watching.", phrases: custom),
            .init(name: "disabled default", input: "Ready. Thanks for watching!", expected: "Ready. Thanks for watching!", enabled: false),
            .init(name: "disabled custom", input: "Ready. End of dictation.", expected: "Ready. End of dictation.", enabled: false, phrases: custom),
            .init(name: "empty lists", input: "Thanks for watching!", expected: "Thanks for watching!", phrases: .init(sentences: [], endings: [])),
            .init(name: "empty output", input: "", expected: ""),
            .init(name: "whitespace output", input: " \n\t", expected: ""),
            .init(name: "filter before autocorrect", input: "Ready. Thanks for watching!", expected: "formatted:Ready.", autocorrect: true),
            .init(name: "empty output skips autocorrect", input: "Thanks for watching!", expected: "", autocorrect: true),
        ]
        var failures = 0
        var count = 0
        for version in ["v2", "v3"] {
            let engine = FluidAudioEngine(modelVersion: version)
            try await engine.initialize()
            let url = directory.appendingPathComponent("\(version).txt")
            var versionCases = cases
            if version == "v3" {
                versionCases += [
                    .init(name: "Russian ending", input: "Отчёт готов. Продолжение следует.", expected: "Отчёт готов."),
                    .init(name: "Russian credit", input: "Субтитры создавал Дима Торзок.", expected: ""),
                ]
            }
            for scenario in versionCases {
                try scenario.input.write(to: url, atomically: true, encoding: .utf8)
                var settings = Settings()
                settings.filterWhisperHallucinations = scenario.enabled
                settings.whisperFilterPhrases = scenario.phrases
                settings.shouldApplyAsianAutocorrect = scenario.autocorrect
                let actual = try await engine.transcribeAudio(url: url, settings: settings)
                count += 1
                if actual != scenario.expected {
                    failures += 1
                    print("FAIL Parakeet \(version) \(scenario.name): expected \(scenario.expected.debugDescription), got \(actual.debugDescription)")
                }
            }
        }
        print("Parakeet engine integration: \(count) checks, \(failures) failures (stub ASR)")
        if failures > 0 { exit(1) }
    }
}
