import AudioEngine
import AVFoundation
import Speech

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
    private let recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var currentText = ""
    private var didEmitLanguage = false

    public init(adapter: WhisperTranscribing = WhisperAdapter(), recognizer: SFSpeechRecognizer? = SFSpeechRecognizer()) {
        self.adapter = adapter
        self.recognizer = recognizer
    }

    public func process(chunk: PCMChunk) {
        if shouldUseSpeech() {
            processWithSpeech(chunk: chunk)
            return
        }
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
        if request != nil {
            request?.endAudio()
            return
        }
        onFinal?(currentText)
        resetState()
    }

    private func shouldUseSpeech() -> Bool {
        guard let recognizer else { return false }
        return recognizer.isAvailable && SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    private func processWithSpeech(chunk: PCMChunk) {
        if request == nil {
            request = SFSpeechAudioBufferRecognitionRequest()
            request?.shouldReportPartialResults = true
            request?.requiresOnDeviceRecognition = true
            task = recognizer?.recognitionTask(with: request!, resultHandler: { [weak self] result, error in
                guard let self else { return }
                if let result = result {
                    currentText = result.bestTranscription.formattedString
                    if result.isFinal {
                        onFinal?(currentText)
                        resetState()
                    } else {
                        onPartial?(currentText)
                    }
                } else if error != nil {
                    onFinal?(currentText)
                    resetState()
                }
            })
        }

        let frameCount = chunk.data.count / MemoryLayout<Float>.size
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: chunk.sampleRate, channels: 1, interleaved: false),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
            return
        }
        buffer.frameLength = AVAudioFrameCount(frameCount)
        chunk.data.withUnsafeBytes { rawBuffer in
            guard let source = rawBuffer.bindMemory(to: Float.self).baseAddress else { return }
            buffer.floatChannelData?.pointee.assign(from: source, count: frameCount)
        }
        request?.append(buffer)
    }

    private func resetState() {
        currentText = ""
        didEmitLanguage = false
        request = nil
        task = nil
    }
}
