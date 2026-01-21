import XCTest
@testable import Voxify

final class VoiceCommandParserTests: XCTestCase {
    func testParsesUndoCommand() {
        let parser = VoiceCommandParser()
        let command = parser.parse("command: undo")
        XCTAssertEqual(command?.action, .undo)
    }

    func testParsesNewParagraphCommand() {
        let parser = VoiceCommandParser()
        let command = parser.parse("command: new paragraph")
        XCTAssertEqual(command?.action, .newParagraph)
    }

    func testIgnoresNonCommandText() {
        let parser = VoiceCommandParser()
        let command = parser.parse("please undo that")
        XCTAssertNil(command)
    }
}
