import XCTest
import RxBlocking
@testable import SmartAI

final class DefaultOnDeviceQualityInspectionUseCaseTests: XCTestCase {
    func test_등급이_네개를_넘으면_상위_네개만_남긴다() throws {
        let repository = given("분류기가 여섯 등급을 돌려준다") {
            StubOnDeviceBananaQualityRepository(result: .just(.fixture(grades: [
                .fixture(name: "정상", probability: 0.61),
                .fixture(name: "과숙", probability: 0.20),
                .fixture(name: "미숙", probability: 0.10),
                .fixture(name: "손상", probability: 0.05),
                .fixture(name: "곰팡이", probability: 0.03),
                .fixture(name: "기타", probability: 0.01),
            ])))
        }
        let useCase = given("온디바이스 유즈케이스를 만든다") {
            DefaultOnDeviceQualityInspectionUseCase(repository: repository)
        }

        let assessment = try when("판별을 실행한다") {
            try useCase.execute(photo: .fixture()).toBlocking().single()
        }

        then("앞쪽 네 등급만 순서를 유지한 채 남는다") {
            XCTAssertEqual(assessment.grades.map(\.name), ["정상", "과숙", "미숙", "손상"])
        }
    }

    func test_등급이_네개_이하면_그대로_유지한다() throws {
        let useCase = given("분류기가 두 등급만 돌려준다") {
            DefaultOnDeviceQualityInspectionUseCase(
                repository: StubOnDeviceBananaQualityRepository(result: .just(.fixture(grades: [
                    .fixture(name: "정상", probability: 0.8),
                    .fixture(name: "과숙", probability: 0.2),
                ])))
            )
        }

        let assessment = try when("판별을 실행한다") {
            try useCase.execute(photo: .fixture()).toBlocking().single()
        }

        then("두 등급이 그대로 남는다") {
            XCTAssertEqual(assessment.grades.map(\.name), ["정상", "과숙"])
        }
    }

    func test_상위_등급_이름은_잘라내도_바뀌지_않는다() throws {
        let useCase = given("상위 등급이 정상인 결과를 돌려준다") {
            DefaultOnDeviceQualityInspectionUseCase(
                repository: StubOnDeviceBananaQualityRepository(result: .just(.fixture(
                    topGradeName: "정상",
                    grades: (1...6).map { .fixture(name: "등급\($0)", probability: Float(1) / Float($0)) }
                )))
            )
        }

        let assessment = try when("판별을 실행한다") {
            try useCase.execute(photo: .fixture()).toBlocking().single()
        }

        then("상위 등급 이름이 유지된다") {
            XCTAssertEqual(assessment.topGradeName, "정상")
            XCTAssertEqual(assessment.grades.count, 4)
        }
    }
}
