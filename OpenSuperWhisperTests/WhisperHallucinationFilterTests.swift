import Foundation
#if !FILTER_STANDALONE_TEST
import XCTest
@testable import OpenSuperWhisper
#endif

private let filterCases: [(name: String, input: String, expected: String)] = [
    ("Russian credit", "Субтитры создавал DimaTorzok", ""),
    ("Russian credit after text", "Отправь отчёт. Субтитры добавил DimaTorzok.", "Отправь отчёт."),
    ("Quoted credit name", "Субтитры подогнал «Симон»!", ""),
    ("Initials in credit", "Редактор субтитров М.Лосева Корректор А.Егорова", ""),
    ("Credit in the middle", "Первое. Субтитры создавал DimaTorzok. Второе.", "Первое. Второе."),
    ("English credit", "Subtitles by the Amara.org community.", ""),
    ("Russian outro", "Нужен отчёт. Продолжение следует…", "Нужен отчёт."),
    ("Russian viewing outro", "Спасибо за просмотр!", ""),
    ("Subscription outro", "Готово. Подписывайтесь на мой канал.", "Готово."),
    ("English outro", "Send the report. Thanks for watching!", "Send the report."),
    ("English viewing outro", "Thank you for watching this video.", ""),
    ("Repeated endings", "Задача готова. Спасибо за просмотр! Продолжение следует...", "Задача готова."),
    ("Outro followed by credit", "Задача готова. Продолжение следует. Субтитры создавал DimaTorzok.", "Задача готова."),
    ("Credit followed by outro", "Задача готова. Субтитры создавал DimaTorzok. Продолжение следует.", "Задача готова."),
    ("Case and whitespace", "  ПРОДОЛЖЕНИЕ\u{00a0}СЛЕДУЕТ...\n", ""),
    ("Unicode before match", "🙂 Всё готово. Продолжение следует...", "🙂 Всё готово."),
    ("Ordinary thanks", "Спасибо!", "Спасибо!"),
    ("English thanks", "Thank you.", "Thank you."),
    ("Everyday words", "Да. Хорошо. Поехали!", "Да. Хорошо. Поехали!"),
    ("Literal quotation", "Он сказал: «Продолжение следует». Это цитата.", "Он сказал: «Продолжение следует». Это цитата."),
    ("Quoted sentence at end", "«Продолжение следует!»", "«Продолжение следует!»"),
    ("Instruction mentioning phrase", "Добавь фразу Спасибо за просмотр.", "Добавь фразу Спасибо за просмотр."),
    ("Sentence prefix", "Продолжение следует обсудить завтра.", "Продолжение следует обсудить завтра."),
    ("Longer sentence", "Спасибо за просмотр результатов теста.", "Спасибо за просмотр результатов теста."),
    ("Outro in body", "Спасибо за просмотр. Теперь обсудим замечания.", "Спасибо за просмотр. Теперь обсудим замечания."),
    ("Name in ordinary speech", "Субтитры создавал DimaTorzok вместе с командой.", "Субтитры создавал DimaTorzok вместе с командой."),
    ("Unlisted credit", "Субтитры создавал Алексей.", "Субтитры создавал Алексей."),
    ("Empty", "", ""),
    ("Whitespace", " \n\t", " \n\t"),
    ("Literal music discussion", "Включи спокойную музыку и продолжай.", "Включи спокойную музыку и продолжай."),
]

private func checkFilter() -> (checks: Int, failures: [String]) {
    var failures: [String] = []
    var checks = 0
    for test in filterCases {
        let actual = WhisperHallucinationFilter.filterSegments([test.input]).joined()
        checks += 1
        if actual != test.expected {
            failures.append("\(test.name): expected \(test.expected.debugDescription), got \(actual.debugDescription)")
        }
        checks += 1
        if WhisperHallucinationFilter.filterSegments([test.input], enabled: false) != [test.input] {
            failures.append("\(test.name): disabled filter changed input")
        }
        // Decoder boundaries may fall in the middle of a phrase. Move the
        // boundary through every character, including punctuation and emoji.
        for boundary in test.input.indices {
            let segments = [String(test.input[..<boundary]), String(test.input[boundary...])]
            let filtered = WhisperHallucinationFilter.filterSegments(segments)
            checks += 1
            if filtered.count != segments.count || filtered.joined() != test.expected {
                failures.append("\(test.name): result depends on decoder boundary")
                break
            }
        }
    }
    let input = ["🙂 Отчёт.", " Продолжение", " следует...", ""]
    let expected = ["🙂 Отчёт.", "", "", ""]
    checks += 1
    if WhisperHallucinationFilter.filterSegments(input) != expected {
        failures.append("Segment indices changed; timestamp association would be lost")
    }
    checks += 1
    if WhisperHallucinationFilter.filterSegments([]) != [] {
        failures.append("Empty segment list changed")
    }
    let suite = "WhisperPhraseEditorTests." + UUID().uuidString
    if let prefs = UserDefaults(suiteName: suite) {
        defer { prefs.removePersistentDomain(forName: suite) }
        func expect(_ value: Bool, _ message: String) {
            checks += 1
            if !value { failures.append(message) }
        }
        expect(WhisperPhraseList.load(from: prefs) == .standard, "First launch has all standard phrases")
        let endings = WhisperPhraseList.lines(in: "  Вот   и всё!  \n\nВОТ И ВСЁ!\r\nC++ [test]")
        expect(endings == ["Вот и всё!", "C++ [test]"], "Lines should trim, merge whitespace and omit duplicates")
        let custom = WhisperPhraseList(sentences: ["Реклама канала"], endings: endings)
        custom.save(to: prefs)
        let loaded = WhisperPhraseList.load(from: prefs)
        expect(loaded == custom, "Saved edits should reload")
        func filtered(_ input: [String]) -> String {
            WhisperHallucinationFilter.filterSegments(input, phrases: loaded).joined()
        }
        expect(filtered(["Готово. Вот", " и всё!"]) == "Готово.", "Edited closing phrase across segments")
        expect(filtered(["Реклама канала. План готов."]) == " План готов.", "Custom sentence in the middle")
        expect(filtered(["Вот и всё! Продолжаем."]) == "Вот и всё! Продолжаем.", "Custom ending in the middle is kept")
        expect(filtered(["Готово. Спасибо за просмотр."]) == "Готово. Спасибо за просмотр.", "Deleted default should stop matching")
        expect(filtered(["Готово. C++ [test]!"]) == "Готово.", "Literal regex metacharacters")
        expect(filtered(["Готово. C t!"]) == "Готово. C t!", "Punctuation must not become regex syntax")
        expect(WhisperHallucinationFilter.filterSegments(["Вот и всё!"], enabled: false, phrases: loaded) == ["Вот и всё!"], "Disabled custom filter")
        let empty = WhisperPhraseList(sentences: [], endings: [])
        empty.save(to: prefs)
        expect(WhisperPhraseList.load(from: prefs) == empty, "Intentionally empty list persists")
        expect(WhisperHallucinationFilter.filterSegments(["Спасибо за просмотр!"], phrases: empty) == ["Спасибо за просмотр!"], "Empty list filters nothing")
        WhisperPhraseList.standard.save(to: prefs)
        expect(WhisperPhraseList.load(from: prefs) == .standard, "Restored defaults persist")
    } else {
        failures.append("Could not create isolated preferences")
    }
    return (checks, failures)
}

#if FILTER_STANDALONE_TEST
@main
private enum FilterTestRunner {
    static func main() {
        let result = checkFilter()
        for failure in result.failures { print("FAIL: \(failure)") }
        print("\(result.checks) checks, \(result.failures.count) failures")
        if !result.failures.isEmpty { exit(1) }
    }
}
#else
final class WhisperHallucinationFilterTests: XCTestCase {
    func testFilteringAndDecoderBoundaries() {
        let result = checkFilter()
        XCTAssertTrue(result.failures.isEmpty, result.failures.joined(separator: "\n"))
    }
}
#endif
