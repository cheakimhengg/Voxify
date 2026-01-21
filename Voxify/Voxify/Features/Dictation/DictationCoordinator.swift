import AudioEngine
import PolishingService
import Shared
import STTService
import TextInserter

final class DictationCoordinator {
    private let audioCapture: AudioCapturing
    private let sttService: STTServicing
    private let polishingService: PolishingServicing
    private let textInserter: TextInserting
    private let commandParser: VoiceCommandParser
    private let commandExecutor: VoiceCommandExecutor
    private let dictionaryStore: DictionaryStore?

    private(set) var session: DictationSession?
    var onUpdate: ((String, String, Bool) -> Void)?

    init(
        audioCapture: AudioCapturing = AudioCapture(),
        sttService: STTServicing = STTService(),
        polishingService: PolishingServicing = PolishingService(),
        textInserter: TextInserting = TextInserter(),
        commandParser: VoiceCommandParser = VoiceCommandParser(),
        commandExecutor: VoiceCommandExecutor = VoiceCommandExecutor(),
        dictionaryStore: DictionaryStore? = DictionaryStore()
    ) {
        self.audioCapture = audioCapture
        self.sttService = sttService
        self.polishingService = polishingService
        self.textInserter = textInserter
        self.commandParser = commandParser
        self.commandExecutor = commandExecutor
        self.dictionaryStore = dictionaryStore
    }

    func start(appBundleId: String) {
        session = DictationSession(appBundleId: appBundleId)
        _ = session?.transition(to: .listening)

        sttService.onPartial = { [weak self] rawText in
            self?.handlePartial(rawText)
        }

        sttService.onFinal = { [weak self] rawText in
            self?.handleFinal(rawText)
        }

        sttService.onLanguageDetection = { [weak self] codes in
            self?.handleLanguageCodes(codes)
        }

        audioCapture.onPCMChunk = { [weak self] chunk in
            self?.sttService.process(chunk: chunk)
        }

        try? audioCapture.start()
    }

    func stop() {
        audioCapture.stop()
        sttService.finalize()
    }

    private func handlePartial(_ rawText: String) {
        guard var session else { return }
        session.rawText = rawText
        let terms = dictionaryStore?.load().filter { $0.isEnabled }.map { $0.term } ?? []
        let polished = polishingService.polish(rawText, preserving: terms)
        session.polishedText = polished
        self.session = session
        onUpdate?(rawText, polished, false)
    }

    private func handleFinal(_ rawText: String) {
        guard var session else { return }
        session.rawText = rawText
        if let command = commandParser.parse(rawText) {
            let updatedText = commandExecutor.apply(command, to: "")
            _ = textInserter.insert(updatedText)
            _ = session.transition(to: .completed)
            self.session = session
            onUpdate?(rawText, updatedText, true)
            return
        }

        let terms = dictionaryStore?.load().filter { $0.isEnabled }.map { $0.term } ?? []
        let polished = polishingService.polish(rawText, preserving: terms)
        session.polishedText = polished
        _ = session.transition(to: .completed)
        self.session = session
        _ = textInserter.insert(polished)
        onUpdate?(rawText, polished, true)
    }

    private func handleLanguageCodes(_ codes: [String]) {
        guard var session else { return }
        session.languageCodes = codes
        self.session = session
    }
}
