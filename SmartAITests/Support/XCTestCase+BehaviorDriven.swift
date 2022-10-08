import XCTest

extension XCTestCase {
    @discardableResult
    func given<Value>(_ description: String, _ body: () throws -> Value) rethrows -> Value {
        try XCTContext.runActivity(named: "Given \(description)") { _ in try body() }
    }

    @discardableResult
    func when<Value>(_ description: String, _ body: () throws -> Value) rethrows -> Value {
        try XCTContext.runActivity(named: "When \(description)") { _ in try body() }
    }

    func then(_ description: String, _ body: () throws -> Void) rethrows {
        try XCTContext.runActivity(named: "Then \(description)") { _ in try body() }
    }
}
