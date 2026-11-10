import Foundation

struct WhisperPhraseList: Equatable {
    var sentences: [String]
    var endings: [String]

    static let namePlaceholder = "{И.Фамилия}"
    static let standard: Self = {
        let credits = ["создавал", "создал", "добавил", "сделал"].flatMap { verb in
            ["DimaTorzok", "Дима Торзок", "ДимаТорзок"].map { "Субтитры \(verb) \($0)" }
        }
        return Self(sentences: credits + [
            "Субтитры подогнал Симон", "Субтитры подогнал «Симон»",
            "Редактор субтитров \(namePlaceholder)",
            "Редактор субтитров \(namePlaceholder) Корректор \(namePlaceholder)",
            "Subtitles by the Amara.org community", "Subtitles by Amara.org community",
        ], endings: [
            "Продолжение следует", "Спасибо за просмотр", "Всем спасибо за просмотр",
            "Подписывайтесь на канал", "Подписывайтесь на мой канал",
            "Подписывайтесь на наш канал", "Подпишись на канал",
            "Thank you for watching", "Thanks for watching",
            "Thank you for watching this video", "Thanks for watching this video", "Please subscribe",
        ])
    }()

    private static let key = "whisperFilterPhraseList.v1"

    static func load(from defaults: UserDefaults = .standard) -> Self {
        guard let list = defaults.dictionary(forKey: key),
              let sentences = list["sentences"] as? [String],
              let endings = list["endings"] as? [String] else { return .standard }
        return Self(sentences: sentences, endings: endings)
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(["sentences": sentences, "endings": endings], forKey: Self.key)
    }

    static func lines(in text: String) -> [String] {
        var seen = Set<String>()
        return text.split(whereSeparator: \.isNewline).compactMap { line in
            let phrase = line.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            guard !phrase.isEmpty, seen.insert(phrase.lowercased()).inserted else { return nil }
            return phrase
        }
    }
}

// Phrase sources and matching boundaries: docs/whisper_hallucination_filter.md.
enum WhisperHallucinationFilter {
    private static func pattern(for phrase: String) -> String? {
        // Sentence-ending punctuation is already consumed by the outer pattern.
        let body = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"[.!?…]+$"#, with: "", options: .regularExpression)
        let words = body.split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return nil }
        return words.map { word in
            if word == WhisperPhraseList.namePlaceholder {
                return #"[а-яё]\s*\.\s*[а-яё-]+"#
            }
            return NSRegularExpression.escapedPattern(for: String(word))
                .replacingOccurrences(of: "«", with: #"[«"“]"#)
                .replacingOccurrences(of: "»", with: #"[»"”]"#)
        }.joined(separator: #"\s+"#)
    }

    private struct Expressions {
        let sentences: NSRegularExpression?
        let endings: NSRegularExpression?

        init(_ list: WhisperPhraseList) throws {
            func compile(_ phrases: [String], before: String, after: String) throws -> NSRegularExpression? {
                let alternatives = phrases.compactMap(pattern(for:))
                guard !alternatives.isEmpty else { return nil }
                return try NSRegularExpression(pattern: before + "(?:" + alternatives.joined(separator: "|") + ")" + after,
                                               options: [.caseInsensitive])
            }
            sentences = try compile(list.sentences, before: #"(?:\A|(?<=[.!?…\r\n]))[ \t]*"#,
                                    after: #"[ \t]*(?:[.!?…]+(?=\s|\z)|(?=[\r\n]|\z))"#)
            endings = try compile(list.endings, before: #"(?:\A|(?<=[.!?…\r\n]))\s*"#, after: #"[ \t]*[.!?…]*\s*\z"#)
        }
    }

    private static let standardExpressions = try! Expressions(.standard)

    static func validate(_ list: WhisperPhraseList) throws {
        _ = try Expressions(list)
    }

    /// Returns one string per input segment. Matching uses the joined text, so
    /// a phrase split across decoder segments is still recognised. Deletions
    /// are mapped back to the original UTF-16 ranges to preserve all other
    /// characters, whitespace, and the caller's segment timestamps.
    static func filterSegments(_ segments: [String], enabled: Bool = true, phrases: WhisperPhraseList = .standard) -> [String] {
        guard enabled, !segments.isEmpty else { return segments }
        let expressions = phrases == .standard ? standardExpressions : try? Expressions(phrases)
        guard let expressions else { return segments }
        let joined = segments.joined() as NSString
        let fullRange = NSRange(location: 0, length: joined.length)
        var removals = expressions.sentences?.matches(in: joined as String, range: fullRange).map(\.range) ?? []

        // Mask instead of deleting while finding repeated tails: all ranges
        // continue to refer to the original text, including surrogate pairs.
        let masked = NSMutableString(string: joined as String)
        for range in removals {
            masked.replaceCharacters(in: range, with: String(repeating: " ", count: range.length))
        }
        while let match = expressions.endings?.firstMatch(in: masked as String, range: fullRange) {
            removals.append(match.range)
            masked.replaceCharacters(in: match.range, with: String(repeating: " ", count: match.range.length))
        }
        guard !removals.isEmpty else { return segments }

        var merged: [NSRange] = []
        for range in removals.sorted(by: { $0.location < $1.location }) {
            if let last = merged.last, range.location <= NSMaxRange(last) {
                merged[merged.count - 1] = NSUnionRange(last, range)
            } else {
                merged.append(range)
            }
        }

        var offset = 0
        return segments.map { segment in
            let text = NSMutableString(string: segment)
            let originalRange = NSRange(location: offset, length: text.length)
            offset += text.length
            for removal in merged.reversed() {
                let overlap = NSIntersectionRange(originalRange, removal)
                guard overlap.length > 0 else { continue }
                text.deleteCharacters(in: NSRange(
                    location: overlap.location - originalRange.location,
                    length: overlap.length
                ))
            }
            return text as String
        }
    }
}
