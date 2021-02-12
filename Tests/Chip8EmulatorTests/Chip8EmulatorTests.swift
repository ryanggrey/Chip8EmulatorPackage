import XCTest
@testable import Chip8Emulator

final class Chip8EmulatorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Chip8Emulator().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
