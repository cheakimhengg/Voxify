import AudioEngine

public protocol STTServicing: AnyObject {
    var onPartial: ((String) -> Void)? { get set }
    var onFinal: ((String) -> Void)? { get set }
    var onLanguageDetection: (([String]) -> Void)? { get set }
    func process(chunk: PCMChunk)
    func finalize()
}

public final class STTService: STTServicing {
    public var onPartial: ((String) -> Void)?
    public var onFinal: ((String) -> Void)?
    public var onLanguageDetection: (([String]) -> Void)?

    private let adapter: WhisperTranscribing
    private var currentText = ""
    private var didEmitLanguage = false

    public init(adapter: WhisperTranscribing = WhisperAdapter()) {
        self.adapter = adapter
    }

    public func process(chunk: PCMChunk) {
        if !didEmitLanguage {
            onLanguageDetection?(["en-US"])
            didEmitLanguage = true
        }
        let fragment = adapter.transcribe(chunk: chunk)
        if currentText.isEmpty {
            currentText = fragment
        } else {
            currentText += " " + fragment
        }
        onPartial?(currentText)
    }

    public func finalize() {
        onFinal?(currentText)
    }
}
