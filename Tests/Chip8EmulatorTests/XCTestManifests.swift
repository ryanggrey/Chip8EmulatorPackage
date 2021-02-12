import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Chip8EmulatorTests.allTests),
    ]
}
#endif
