import Shared
import XCTest
@testable import Voxify

final class DictationSessionTests: XCTestCase {
    func testValidTransitions() {
        let validTransitions: [(DictationStatus, DictationStatus)] = [
            (.idle, .listening),
            (.listening, .processing),
            (.processing, .completed),
            (.listening, .paused),
            (.paused, .listening),
            (.idle, .error),
            (.listening, .error),
            (.processing, .error),
            (.paused, .error)
        ]

        for (from, to) in validTransitions {
            XCTAssertTrue(DictationSession.isValidTransition(from: from, to: to), "Expected transition from \(from) to \(to) to be valid")
        }
    }

    func testInvalidTransitions() {
        XCTAssertFalse(DictationSession.isValidTransition(from: .idle, to: .completed))
        XCTAssertFalse(DictationSession.isValidTransition(from: .completed, to: .listening))
        XCTAssertFalse(DictationSession.isValidTransition(from: .processing, to: .paused))
    }

    func testCompletionSetsEndDate() {
        var session = DictationSession(appBundleId: "com.example.test")
        XCTAssertTrue(session.transition(to: .listening))
        XCTAssertTrue(session.transition(to: .processing))
        XCTAssertTrue(session.transition(to: .completed))
        XCTAssertNotNil(session.endedAt)
    }
}
