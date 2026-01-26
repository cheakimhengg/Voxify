import AVFoundation

/// Text-to-Speech service using AVSpeechSynthesizer
final class TTSService: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var completion: (() -> Void)?

    /// Whether TTS is currently speaking
    @Published private(set) var isSpeaking = false

    /// Available voices grouped by language
    static var availableVoices: [(id: String, name: String, language: String)] {
        AVSpeechSynthesisVoice.speechVoices().map { voice in
            (id: voice.identifier, name: voice.name, language: voice.language)
        }
    }

    /// Get voices for a specific language code (e.g., "en-US", "km-KH")
    static func voices(for languageCode: String) -> [(id: String, name: String)] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix(languageCode.prefix(2)) }
            .map { (id: $0.identifier, name: $0.name) }
    }

    /// Get the default voice for the current locale
    static var defaultVoice: String {
        "default"
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Speak the given text
    /// - Parameters:
    ///   - text: The text to speak
    ///   - voice: The voice identifier (use "default" for system default)
    ///   - rate: Speaking rate (0.0 to 1.0, where 0.5 is normal)
    ///   - completion: Called when speech finishes
    func speak(_ text: String, voice: String = "default", rate: Float = 0.5, completion: (() -> Void)? = nil) {
        stop()

        let utterance = AVSpeechUtterance(string: text)

        // Set voice
        if voice != "default" && !voice.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice)
        } else {
            // Use system default voice based on locale
            utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US")
        }

        // Convert rate (0.0-1.0) to AVSpeechUtteranceRate
        // AVSpeechUtteranceDefaultSpeechRate is about 0.5
        // Range is from AVSpeechUtteranceMinimumSpeechRate to AVSpeechUtteranceMaximumSpeechRate
        let minRate = AVSpeechUtteranceMinimumSpeechRate
        let maxRate = AVSpeechUtteranceMaximumSpeechRate
        utterance.rate = minRate + (maxRate - minRate) * rate

        // Set pitch (1.0 is normal)
        utterance.pitchMultiplier = 1.0

        // Set volume
        utterance.volume = 1.0

        self.completion = completion
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    /// Stop speaking
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        completion = nil
    }

    /// Pause speaking
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    /// Resume speaking
    func resume() {
        synthesizer.continueSpeaking()
    }

    /// Check if paused
    var isPaused: Bool {
        synthesizer.isPaused
    }
}

extension TTSService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.completion?()
            self?.completion = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.completion = nil
        }
    }
}
