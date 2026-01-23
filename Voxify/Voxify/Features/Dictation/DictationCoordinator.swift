import AudioEngine
import Foundation
import PolishingService
import Shared
import STTService
import TextInserter

enum DictationMode {
    case holdToTalk
    case continuous
}

final class DictationCoordinator {
    private let audioCapture: AudioCapturing
    private let sttService: STTServicing
    private let polishingService: PolishingServicing
    private let textInserter: TextInserting
    private let commandParser: VoiceCommandParser
    private let commandExecutor: VoiceCommandExecutor
    private let dictionaryStore: DictionaryStore?
    private let usageStore: UsageStore
    private let settingsStore: SettingsStore
    private let historyStore: HistoryStore
    private let appToneMapper: AppToneMapper

    private(set) var session: DictationSession?
    var onUpdate: ((String, String, Bool) -> Void)?
    var onNoFocus: ((String) -> Void)?
    var onAudioLevel: ((Float) -> Void)?

    private var mode: DictationMode = .holdToTalk
    private var pauseThresholdSeconds: Double = 3.5
    private var silenceThreshold: Float = 0.02
    private var lastSpeechAt: Date = Date()
    private var segmentStartedAt: Date = Date()

    init(
        audioCapture: AudioCapturing = AudioCapture(),
        sttService: STTServicing = STTService(),
        polishingService: PolishingServicing = PolishingService(),
        textInserter: TextInserting = TextInserter(),
        commandParser: VoiceCommandParser = VoiceCommandParser(),
        commandExecutor: VoiceCommandExecutor = VoiceCommandExecutor(),
        dictionaryStore: DictionaryStore? = DictionaryStore(),
        usageStore: UsageStore = UsageStore(),
        settingsStore: SettingsStore = SettingsStore(),
        historyStore: HistoryStore = HistoryStore(),
        appToneMapper: AppToneMapper = AppToneMapper()
    ) {
        self.audioCapture = audioCapture
        self.sttService = sttService
        self.polishingService = polishingService
        self.textInserter = textInserter
        self.commandParser = commandParser
        self.commandExecutor = commandExecutor
        self.dictionaryStore = dictionaryStore
        self.usageStore = usageStore
        self.settingsStore = settingsStore
        self.historyStore = historyStore
        self.appToneMapper = appToneMapper
    }

    func start(appBundleId: String, mode: DictationMode, pauseThresholdSeconds: Double, silenceThreshold: Float) {
        self.mode = mode
        self.pauseThresholdSeconds = pauseThresholdSeconds
        self.silenceThreshold = silenceThreshold
        session = DictationSession(appBundleId: appBundleId)
        _ = session?.transition(to: .listening)
        segmentStartedAt = Date()
        lastSpeechAt = Date()

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
            self?.handlePCM(chunk)
        }

        try? audioCapture.start()
    }

    func stop() {
        audioCapture.stop()
        sttService.finalize()
    }

    private func handlePCM(_ chunk: PCMChunk) {
        // Emit audio level for waveform visualization
        onAudioLevel?(chunk.rms)

        if chunk.rms > silenceThreshold {
            lastSpeechAt = Date()
        } else if mode == .continuous {
            let elapsed = Date().timeIntervalSince(lastSpeechAt)
            if elapsed >= pauseThresholdSeconds {
                sttService.finalize()
                lastSpeechAt = Date()
                return
            }
        }
        sttService.process(chunk: chunk)
    }

    private func handlePartial(_ rawText: String) {
        guard var session else { return }
        session.rawText = rawText
        let terms = dictionaryStore?.load().filter { $0.isEnabled }.map { $0.term } ?? []
        let settings = settingsStore.load()
        let polished = polishedText(from: rawText, terms: terms, settings: settings)
        session.polishedText = polished
        self.session = session
        onUpdate?(rawText, polished, false)
    }

    private func handleFinal(_ rawText: String) {
        guard var session else { return }
        session.rawText = rawText
        if let command = commandParser.parse(rawText) {
            if command.action == .undo {
                _ = textInserter.send(.undo)
                onUpdate?(rawText, "Undo", true)
                return
            }
            if command.action == .redo {
                _ = textInserter.send(.redo)
                onUpdate?(rawText, "Redo", true)
                return
            }

            let selection = textInserter.focusedTextState()
            let updatedText = commandExecutor.apply(command, to: selection?.selectedText ?? "")
            let inserted = textInserter.insert(updatedText)
            if !inserted {
                onNoFocus?(updatedText)
            }
            _ = session.transition(to: .completed)
            self.session = session
            onUpdate?(rawText, updatedText, true)
            recordUsage(rawText: rawText, polishedText: updatedText)
            resetSessionIfContinuous(appBundleId: session.appBundleId)
            return
        }

        let terms = dictionaryStore?.load().filter { $0.isEnabled }.map { $0.term } ?? []
        let settings = settingsStore.load()
        let polished = polishedText(from: rawText, terms: terms, settings: settings)
        session.polishedText = polished
        _ = session.transition(to: .completed)
        self.session = session
        let inserted = textInserter.insert(polished)
        if !inserted {
            onNoFocus?(polished)
        }
        onUpdate?(rawText, polished, true)
        recordUsage(rawText: rawText, polishedText: polished)
        resetSessionIfContinuous(appBundleId: session.appBundleId)
    }

    private func handleLanguageCodes(_ codes: [String]) {
        guard var session else { return }
        session.languageCodes = codes
        self.session = session
    }

    private func polishedText(from rawText: String, terms: [String], settings: VoxifySettings) -> String {
        guard settings.polishingEnabled else { return rawText }

        // Determine context-aware tone based on active app
        let appBundleId = session?.appBundleId ?? "unknown"
        let contextTone: ContextTone?

        if settings.contextAwareToneEnabled {
            // Use app-specific tone if available, otherwise use preferred tone from settings
            contextTone = appToneMapper.tone(for: appBundleId) ?? ContextTone(rawValue: settings.preferredTone.lowercased())
        } else {
            // Use the user's preferred tone if context-aware is disabled
            contextTone = ContextTone(rawValue: settings.preferredTone.lowercased())
        }

        let options = PolishingOptions(
            removeFillers: settings.autoRemoveFillers,
            removeRepetitions: settings.repetitionDetection,
            sentenceCase: settings.grammarCorrection,
            midSentenceCorrection: settings.midSentenceCorrectionEnabled,
            autoFormatLists: settings.autoFormatting,
            contextTone: contextTone
        )
        return polishingService.polish(rawText, preserving: terms, options: options)
    }

    private func recordUsage(rawText: String, polishedText: String) {
        let duration = Date().timeIntervalSince(segmentStartedAt)
        let words = polishedText.split { $0.isWhitespace || $0.isNewline }.count
        let appBundleId = session?.appBundleId ?? "unknown"

        // Record to usage stats
        usageStore.recordSession(words: words, duration: duration, appBundleId: appBundleId)

        // Save to history
        let settings = settingsStore.load()
        if !settings.privacyMode {
            historyStore.add(
                rawText: rawText,
                polishedText: polishedText,
                appBundleId: appBundleId,
                durationSeconds: duration
            )
        }

        segmentStartedAt = Date()
    }

    private func resetSessionIfContinuous(appBundleId: String) {
        guard mode == .continuous else { return }
        session = DictationSession(appBundleId: appBundleId)
        _ = session?.transition(to: .listening)
    }
}
