import SwiftUI

struct WhisperPhraseEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editsEndings = true
    @State private var sentences: String
    @State private var endings: String
    @State private var saveError: String?

    init(phrases: WhisperPhraseList) {
        _sentences = State(initialValue: phrases.sentences.joined(separator: "\n"))
        _endings = State(initialValue: phrases.endings.joined(separator: "\n"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Фразы фильтра Whisper").font(.headline)
            Picker("Где удалять фразу", selection: $editsEndings) {
                Text("Только в конце записи").tag(true)
                Text("В любом месте записи").tag(false)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text("По одной фразе на строку. Можно добавлять, менять и удалять строки. Фильтр ищет целые предложения без учёта регистра.")
                .font(.callout)
                .foregroundStyle(.secondary)

            TextEditor(text: editsEndings ? $endings : $sentences)
                .font(.body)
                .disableAutocorrection(true)
                .accessibilityLabel(editsEndings ? "Фразы в конце записи" : "Фразы в любом месте записи")
                .padding(6)
                .background(Color(nsColor: .textBackgroundColor))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.secondary.opacity(0.35)))

            if !editsEndings {
                Text("В титрах {И.Фамилия} обозначает инициал и фамилию, например «М. Лосева».")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let saveError {
                Text(saveError).font(.caption).foregroundStyle(.red)
            }
            HStack {
                Button("По умолчанию") {
                    sentences = WhisperPhraseList.standard.sentences.joined(separator: "\n")
                    endings = WhisperPhraseList.standard.endings.joined(separator: "\n")
                    saveError = nil
                }
                Spacer()
                Button("Отмена") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Сохранить", action: save)
                    .keyboardShortcut("s", modifiers: .command)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 485, height: 395)
    }

    private func save() {
        let list = WhisperPhraseList(sentences: WhisperPhraseList.lines(in: sentences),
                                     endings: WhisperPhraseList.lines(in: endings))
        do {
            try WhisperHallucinationFilter.validate(list)
            list.save()
            dismiss()
        } catch {
            saveError = "Не удалось сохранить список. Попробуй сократить его."
        }
    }
}
