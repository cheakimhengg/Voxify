import Foundation
import XCTest
@testable import Voxify

final class DictionaryStoreTests: XCTestCase {
    func testCRUDOperations() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileURL = tempDir.appendingPathComponent("dictionary.json")
        let store = DictionaryStore(fileURL: fileURL)

        let entry = store.add(term: "Voxify", languageCode: "en-US")
        XCTAssertEqual(store.load().count, 1)

        var updated = entry
        updated.term = "Voxify Pro"
        store.update(updated)
        XCTAssertEqual(store.load().first?.term, "Voxify Pro")

        store.remove(id: entry.id)
        XCTAssertTrue(store.load().isEmpty)
    }
}
