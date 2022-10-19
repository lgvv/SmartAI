import XCTest
import RxBlocking
@testable import SmartAI

final class DefaultRemoteQualityInspectionUseCaseTests: XCTestCase {
    func test_오프라인이면_서버를_호출하지_않는다() {
        let repository = given("서버 리포지토리가 준비되어 있다") {
            StubRemoteBananaQualityRepository()
        }
        let useCase = given("네트워크가 끊긴 상태다") {
            DefaultRemoteQualityInspectionUseCase(repository: repository,
                                                  reachability: StubNetworkReachability(isConnected: false))
        }

        let result = when("판별을 실행한다") {
            useCase.execute(photo: .fixture()).toBlocking().materialize()
        }

        then("networkUnavailable로 실패하고 서버 호출이 없다") {
            XCTAssertEqual(repository.assessCallCount, 0)
            guard case let .failed(_, error) = result else {
                return XCTFail("실패하지 않았습니다")
            }
            XCTAssertEqual(error as? QualityInspectionError, .networkUnavailable)
        }
    }

    func test_온라인이면_리포지토리_결과를_그대로_전달한다() throws {
        let expected = QualityAssessment.fixture(source: .server,
                                                 topGradeName: "과숙",
                                                 grades: [.fixture(name: "과숙", probability: 0.71)])
        let repository = given("서버가 과숙 판정을 돌려준다") {
            StubRemoteBananaQualityRepository(result: .just(expected))
        }
        let useCase = given("네트워크가 연결된 상태다") {
            DefaultRemoteQualityInspectionUseCase(repository: repository,
                                                  reachability: StubNetworkReachability(isConnected: true))
        }

        let assessment = try when("판별을 실행한다") {
            try useCase.execute(photo: .fixture()).toBlocking().single()
        }

        then("서버 판정이 변형 없이 전달된다") {
            XCTAssertEqual(assessment, expected)
            XCTAssertEqual(repository.assessCallCount, 1)
        }
    }

    func test_네트워크_상태는_구독_시점에_확인한다() {
        let useCase = given("끊긴 상태로 유즈케이스를 만든다") {
            DefaultRemoteQualityInspectionUseCase(repository: StubRemoteBananaQualityRepository(),
                                                  reachability: StubNetworkReachability(isConnected: false))
        }
        let stream = when("구독하지 않은 스트림만 만들어 둔다") {
            useCase.execute(photo: .fixture())
        }

        then("구독하는 순간 실패가 전달된다") {
            guard case let .failed(_, error) = stream.toBlocking().materialize() else {
                return XCTFail("실패하지 않았습니다")
            }
            XCTAssertEqual(error as? QualityInspectionError, .networkUnavailable)
        }
    }
}
