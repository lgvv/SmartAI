import XCTest
@testable import SmartAI

final class ServerEnvironmentTests: XCTestCase {
    private let key = ServerEnvironment.baseURLInfoDictionaryKey

    func test_주소가_주입되어_있으면_baseURL로_변환한다() throws {
        let infoDictionary = given("Info dictionary에 서버 주소가 있다") {
            StubInfoDictionary(values: [key: "http://127.0.0.1:8000/predict"])
        }

        let environment = try when("환경을 초기화한다") {
            try ServerEnvironment(infoDictionary: infoDictionary)
        }

        then("주입된 주소가 baseURL이 된다") {
            XCTAssertEqual(environment.baseURL.absoluteString, "http://127.0.0.1:8000/predict")
        }
    }

    func test_주소가_없으면_missingBaseURL을_던진다() throws {
        let infoDictionary = given("Info dictionary가 비어 있다") {
            StubInfoDictionary(values: [:])
        }

        try then("초기화가 missingBaseURL로 실패한다") {
            XCTAssertThrowsError(try ServerEnvironment(infoDictionary: infoDictionary)) { error in
                XCTAssertEqual(error as? ServerEnvironment.Failure, .missingBaseURL)
            }
        }
    }

    func test_주소에_host가_없으면_missingBaseURL을_던진다() throws {
        let infoDictionary = given("Info dictionary의 주소가 치환되지 않았다") {
            StubInfoDictionary(values: [key: "$(SERVER_BASE_URL)"])
        }

        try then("초기화가 missingBaseURL로 실패한다") {
            XCTAssertThrowsError(try ServerEnvironment(infoDictionary: infoDictionary)) { error in
                XCTAssertEqual(error as? ServerEnvironment.Failure, .missingBaseURL)
            }
        }
    }

    func test_실행중인_앱_번들은_유효한_주소를_제공한다() throws {
        let environment = try when("앱 번들로 환경을 초기화한다") {
            try ServerEnvironment(infoDictionary: Bundle.main)
        }

        then("baseURL에 host가 존재한다") {
            XCTAssertNotNil(environment.baseURL.host)
        }
    }
}
