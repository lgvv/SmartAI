import Foundation

struct ServerEnvironment {
    enum Failure: Error, Equatable {
        case missingBaseURL
    }

    static let baseURLInfoDictionaryKey = "ServerBaseURL"

    let baseURL: URL

    init(infoDictionary: InfoDictionaryProviding = Bundle.main) throws {
        guard let rawValue = infoDictionary.object(forInfoDictionaryKey: Self.baseURLInfoDictionaryKey) as? String,
              let baseURL = URL(string: rawValue),
              baseURL.host != nil else {
            throw Failure.missingBaseURL
        }

        self.baseURL = baseURL
    }
}
