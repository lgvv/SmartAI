import XCTest
import RxBlocking
@testable import SmartAI

final class DefaultRemoteBananaQualityRepositoryTests: XCTestCase {
    private func dto(from json: String) throws -> BananaResponseDTO {
        try JSONDecoder().decode(BananaResponseDTO.self, from: Data(json.utf8))
    }

    func test_서버_응답을_서버_판정으로_변환한다() throws {
        let response = try given("서버가 두 등급을 돌려준다") {
            try dto(from: """
            {
              "img_name": "a.jpg",
              "banana_classes": { "0": "정상", "1": "과숙" },
              "Probability": { "0": 0.35, "1": 0.65 },
              "argmax": 1
            }
            """)
        }
        let repository = DefaultRemoteBananaQualityRepository(
            apiClient: StubBananaQualityAPIClient(result: .just(response))
        )

        let assessment = try when("판별을 실행한다") {
            try repository.assess(photo: .fixture()).toBlocking(timeout: 10).single()
        }

        then("출처가 서버이고 등급과 확률이 제자리에 들어간다") {
            XCTAssertEqual(assessment.source, .server)
            XCTAssertEqual(assessment.topGradeName, "과숙")
            XCTAssertEqual(assessment.grades.map(\.name), ["정상", "과숙"])
            XCTAssertEqual(assessment.grades.map(\.probability), [0.35, 0.65])
        }
    }

    func test_업로드_실패는_그대로_전파된다() {
        let repository = given("업로드가 실패한다") {
            DefaultRemoteBananaQualityRepository(apiClient: StubBananaQualityAPIClient(
                result: .error(QualityInspectionError.serverRequestFailed(reason: "timeout"))
            ))
        }

        let result = when("판별을 실행한다") {
            repository.assess(photo: .fixture()).toBlocking(timeout: 10).materialize()
        }

        then("serverRequestFailed가 이유와 함께 전파된다") {
            guard case let .failed(_, error) = result else {
                return XCTFail("실패하지 않았습니다")
            }
            XCTAssertEqual(error as? QualityInspectionError, .serverRequestFailed(reason: "timeout"))
        }
    }
}
