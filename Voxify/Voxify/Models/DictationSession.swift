import Foundation
import Shared

struct DictationSession: Identifiable, Equatable {
    let id: UUID
    private(set) var status: DictationStatus
    let startedAt: Date
    private(set) var endedAt: Date?
    let appBundleId: String
    var rawText: String
    var polishedText: String
    var languageCodes: [String]
    let audioDeviceId: String?
    var errorCode: String?

    init(
        id: UUID = UUID(),
        status: DictationStatus = .idle,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        appBundleId: String,
        rawText: String = "",
        polishedText: String = "",
        languageCodes: [String] = [],
        audioDeviceId: String? = nil,
        errorCode: String? = nil
    ) {
        self.id = id
        self.status = status
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.appBundleId = appBundleId
        self.rawText = rawText
        self.polishedText = polishedText
        self.languageCodes = languageCodes
        self.audioDeviceId = audioDeviceId
        self.errorCode = errorCode
    }

    mutating func transition(to newStatus: DictationStatus) -> Bool {
        guard DictationSession.isValidTransition(from: status, to: newStatus) else {
            return false
        }
        status = newStatus
        if newStatus == .completed || newStatus == .error {
            endedAt = Date()
        }
        return true
    }

    static func isValidTransition(from: DictationStatus, to: DictationStatus) -> Bool {
        switch (from, to) {
        case (.idle, .listening),
             (.listening, .processing),
             (.processing, .completed),
             (.listening, .paused),
             (.paused, .listening),
             (.idle, .error),
             (.listening, .error),
             (.processing, .error),
             (.paused, .error):
            return true
        default:
            return false
        }
    }
}
