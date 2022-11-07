import XCTest
import RxSwift
@testable import SmartAI

final class ResultReactorTests: XCTestCase {
    private func makeSUT(
        onDevice: Single<QualityAssessment> = .just(.fixture())
    ) -> (ResultReactor, StubOnDeviceQualityInspectionUseCase) {
        let useCase = StubOnDeviceQualityInspectionUseCase(result: onDevice)
        let reactor = ResultReactor(photo: .fixture(),
                                    onDeviceInspection: useCase,
                                    mutationScheduler: CurrentThreadScheduler.instance)
        return (reactor, useCase)
    }

    func test_화면이_뜨면_온디바이스_판별을_실행한다() {
        let assessment = QualityAssessment.fixture(source: .onDevice,
                                                   topGradeName: "정상",
                                                   grades: [.fixture(name: "정상", probability: 0.9)])
        let (reactor, useCase) = given("온디바이스 판별이 성공한다") { makeSUT(onDevice: .just(assessment)) }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("판정이 상태에 누적되고 상위 등급 이름이 반영된다") {
            XCTAssertEqual(useCase.executeCallCount, 1)
            XCTAssertEqual(reactor.currentState.assessments, [assessment])
            XCTAssertEqual(reactor.currentState.topGradeName, "정상")
        }
    }

    func test_판별이_실패하면_실패_펄스만_발행한다() {
        let (reactor, _) = given("모델을 불러올 수 없다") {
            makeSUT(onDevice: .error(QualityInspectionError.classificationModelUnavailable))
        }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("판정은 비어 있고 실패가 전달된다") {
            XCTAssertTrue(reactor.currentState.assessments.isEmpty)
            XCTAssertEqual(reactor.currentState.failure, .classificationModelUnavailable)
        }
    }

    func test_같은_출처의_판정은_중복으로_쌓이지_않는다() {
        let (reactor, _) = given("온디바이스 판정이 준비되어 있다") { makeSUT() }

        when("viewDidLoad를 두 번 보낸다") {
            reactor.action.onNext(.viewDidLoad)
            reactor.action.onNext(.viewDidLoad)
        }

        then("온디바이스 판정이 하나만 유지된다") {
            XCTAssertEqual(reactor.currentState.assessments.count, 1)
            XCTAssertEqual(reactor.currentState.assessments.first?.source, .onDevice)
        }
    }

    func test_시트가_large가_되면_더보기_버튼이_보인다() {
        let (reactor, _) = given("결과 화면이 medium으로 떠 있다") { makeSUT() }

        when("detent가 large로 바뀐다") {
            reactor.action.onNext(.detentChanged(.large))
        }

        then("더보기 버튼이 보이는 상태다") {
            XCTAssertTrue(reactor.currentState.isMoreInfoVisible)
        }
    }

    func test_시트가_medium으로_돌아가면_더보기_버튼이_숨는다() {
        let (reactor, _) = given("large 상태다") { makeSUT() }
        reactor.action.onNext(.detentChanged(.large))

        when("detent가 medium으로 바뀐다") {
            reactor.action.onNext(.detentChanged(.medium))
        }

        then("더보기 버튼이 숨은 상태다") {
            XCTAssertFalse(reactor.currentState.isMoreInfoVisible)
        }
    }

    func test_더보기를_누르면_현재_판정으로_차트를_요청한다() {
        let assessment = QualityAssessment.fixture(source: .onDevice)
        let (reactor, _) = given("판정이 하나 누적되어 있다") { makeSUT(onDevice: .just(assessment)) }
        reactor.action.onNext(.viewDidLoad)

        when("더보기 버튼 액션을 보낸다") {
            reactor.action.onNext(.moreInfoButtonTapped)
        }

        then("누적된 판정이 차트 요청으로 전달된다") {
            XCTAssertEqual(reactor.currentState.chartRequest, [assessment])
        }
    }
}
