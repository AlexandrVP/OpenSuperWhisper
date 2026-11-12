// Test-only SDK boundary. No model files, network requests or audio decoding.
import Foundation

public enum AsrModelVersion: String { case v2, v3 }
public struct AsrModels {
    let version: AsrModelVersion
    public static func downloadAndLoad(version: AsrModelVersion) async throws -> Self {
        Self(version: version)
    }
}
public struct TdtDecoderState {
    public init(decoderLayers: Int) throws {}
}
public struct AsrResult { public let text: String }
public actor AsrManager {
    public struct Config { public static let `default` = Config() }
    private var version: AsrModelVersion?
    public init(config: Config) {}
    public var decoderLayerCount: Int { 2 }
    public func loadModels(_ models: AsrModels) async throws { version = models.version }
    public var transcriptionProgressStream: AsyncThrowingStream<Double, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(0.5)
            continuation.finish()
        }
    }
    public func transcribe(_ url: URL, decoderState: inout TdtDecoderState) throws -> AsrResult {
        // Verify the production engine initialized the requested model version.
        guard let version, url.lastPathComponent == "\(version.rawValue).txt" else {
            throw CocoaError(.fileReadInvalidFileName)
        }
        return AsrResult(text: try String(contentsOf: url, encoding: .utf8))
    }
}
