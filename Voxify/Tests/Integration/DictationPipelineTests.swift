import AudioEngine
import Foundation
import PolishingService
import STTService
import TextInserter
import XCTest
@testable import Voxify

final class DictationPipelineTests: XCTestCase {
    func testMockAudioProducesPolishedOutput() {
        let audio = MockAudioCapture()
        let stt = MockSTTService()
        let polisher = MockPolisher()
        let inserter = MockTextInserter()

        let coordinator = DictationCoordinator(
            audioCapture: audio,
            sttService: stt,
            polishingService: polisher,
            textInserter: inserter
        )

        var updates: [(String, String, Bool)] = []
        coordinator.onUpdate = { raw, polished, isFinal in
            updates.append((raw, polished, isFinal))
        }

        coordinator.start(appBundleId: "com.example.test", mode: .holdToTalk, pauseThresholdSeconds: 3.5, silenceThreshold: 0.02)
        audio.emit(sequence: 0)
        coordinator.stop()

        XCTAssertEqual(updates.last?.1, "POLISHED: chunk-0")
        XCTAssertEqual(inserter.lastInserted, "POLISHED: chunk-0")
    }
}

final class MockAudioCapture: AudioCapturing {
    var onPCMChunk: ((PCMChunk) -> Void)?

    func start() throws {}

    func stop() {}

    func emit(sequence: Int) {
        let chunk = PCMChunk(sequence: sequence, data: Data([0x00]), sampleRate: 16000, rms: 0.1)
        onPCMChunk?(chunk)
    }
}

final class MockSTTService: STTServicing {
    var onPartial: ((String) -> Void)?
    var onFinal: ((String) -> Void)?
    var onLanguageDetection: (([String]) -> Void)?
    private var currentText = ""

    func process(chunk: PCMChunk) {
        currentText = "chunk-\(chunk.sequence)"
        onPartial?(currentText)
    }

    func finalize() {
        onFinal?(currentText)
    }
}

final class MockPolisher: PolishingServicing {
    func polish(_ text: String) -> String {
        "POLISHED: \(text)"
    }

    func polish(_ text: String, preserving terms: [String]) -> String {
        polish(text)
    }

    func polish(_ text: String, preserving terms: [String], options: PolishingOptions) -> String {
        polish(text)
    }

    func polish(_ text: String, completion: @escaping (String) -> Void) {
        completion(polish(text))
    }
}

final class MockTextInserter: TextInserting {
    private(set) var lastInserted: String?

    @discardableResult
    func insert(_ text: String) -> Bool {
        lastInserted = text
        return true
    }

    func focusedTextState() -> FocusedTextState? {
        nil
    }

    @discardableResult
    func send(_ command: KeyCommand) -> Bool {
        true
    }
}
