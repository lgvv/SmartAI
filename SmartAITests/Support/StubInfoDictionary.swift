@testable import SmartAI

struct StubInfoDictionary: InfoDictionaryProviding {
    private let values: [String: Any]

    init(values: [String: Any]) {
        self.values = values
    }

    func object(forInfoDictionaryKey key: String) -> Any? {
        values[key]
    }
}
