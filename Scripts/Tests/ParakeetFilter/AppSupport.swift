// Only the app collaborators required to compile the real FluidAudioEngine.
// Phrase storage and matching use the production WhisperHallucinationFilter.
import Foundation

struct Settings {
    var filterWhisperHallucinations = true
    var whisperFilterPhrases = WhisperPhraseList.standard
    var shouldApplyAsianAutocorrect = false
}
final class AppPreferences {
    static let shared = AppPreferences()
    var fluidAudioModelVersion = "v3"
}
enum TranscriptionError: Error { case contextInitializationFailed }
enum LanguageUtil {
    static func supportedLanguages(engine: String, fluidAudioModelVersion: String) -> [String] { ["en"] }
}
enum AutocorrectWrapper {
    static func format(_ text: String) -> String { "formatted:\(text)" }
}
