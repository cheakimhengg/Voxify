import Foundation
import PolishingService
import XCTest
@testable import Voxify

final class PerformancePrivacyTests: XCTestCase {
    func testPolishingLatency() {
        let service = PolishingService()
        measure {
            _ = service.polish("quick test")
        }
    }

    func testNoSessionPersistenceByDefault() {
        let fileManager = FileManager.default
        let supportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let sessionFile = supportDir?.appendingPathComponent("Voxify/dictation-session.json")
        XCTAssertFalse(fileManager.fileExists(atPath: sessionFile?.path ?? ""))
    }
}
