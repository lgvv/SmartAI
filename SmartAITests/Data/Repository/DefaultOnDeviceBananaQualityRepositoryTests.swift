import XCTest
import RxBlocking
@testable import SmartAI

final class DefaultOnDeviceBananaQualityRepositoryTests: XCTestCase {
    func test_분류_결과를_온디바이스_판정으로_감싼다() throws {
        let repository = given("분류기가 두 등급을 돌려준다") {
            DefaultOnDeviceBananaQualityRepository(classifier: StubBananaImageClassifier(result: .just([
                .fixture(name: "과숙", probability: 0.82),
                .fixture(name: "정상", probability: 0.18),
            ])))
        }

        let assessment = try when("판별을 실행한다") {
            try repository.assess(photo: .fixture()).toBlocking(timeout: 10).single()
        }

        then("출처가 온디바이스이고 첫 등급이 상위 등급이 된다") {
            XCTAssertEqual(assessment.source, .onDevice)
            XCTAssertEqual(assessment.topGradeName, "과숙")
            XCTAssertEqual(assessment.grades.map(\.name), ["과숙", "정상"])
        }
    }

    func test_분류_결과가_비어_있으면_상위_등급_이름이_빈_문자열이다() throws {
        let repository = given("분류기가 빈 배열을 돌려준다") {
            DefaultOnDeviceBananaQualityRepository(classifier: StubBananaImageClassifier(result: .just([])))
        }

        let assessment = try when("판별을 실행한다") {
            try repository.assess(photo: .fixture()).toBlocking(timeout: 10).single()
        }

        then("빈 문자열이 되고 크래시하지 않는다") {
            XCTAssertEqual(assessment.topGradeName, "")
            XCTAssertTrue(assessment.grades.isEmpty)
        }
    }

    func test_분류_실패는_그대로_전파된다() {
        let repository = given("분류기가 모델 로딩에 실패한다") {
            DefaultOnDeviceBananaQualityRepository(classifier: StubBananaImageClassifier(
                result: .error(QualityInspectionError.classificationModelUnavailable)
            ))
        }

        let result = when("판별을 실행한다") {
            repository.assess(photo: .fixture()).toBlocking(timeout: 10).materialize()
        }

        then("classificationModelUnavailable이 전파된다") {
            guard case let .failed(_, error) = result else {
                return XCTFail("실패하지 않았습니다")
            }
            XCTAssertEqual(error as? QualityInspectionError, .classificationModelUnavailable)
        }
    }
}
