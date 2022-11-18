import XCTest
import RxSwift
@testable import SmartAI

final class ResultReactorTests: XCTestCase {
    private func makeSUT(
        onDevice: Single<QualityAssessment> = .just(.fixture(source: .onDevice)),
        remote: Single<QualityAssessment> = .just(.fixture(source: .server))
    ) -> (ResultReactor, StubOnDeviceQualityInspectionUseCase, StubRemoteQualityInspectionUseCase) {
        let onDeviceUseCase = StubOnDeviceQualityInspectionUseCase(result: onDevice)
        let remoteUseCase = StubRemoteQualityInspectionUseCase(result: remote)
        let reactor = ResultReactor(photo: .fixture(),
                                    onDeviceInspection: onDeviceUseCase,
                                    remoteInspection: remoteUseCase,
                                    mutationScheduler: CurrentThreadScheduler.instance)
        return (reactor, onDeviceUseCase, remoteUseCase)
    }

    func test_화면이_뜨면_두_판별을_모두_실행한다() {
        let (reactor, onDevice, remote) = given("두 판별이 성공한다") { makeSUT() }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("두 판정이 모두 누적된다") {
            XCTAssertEqual(onDevice.executeCallCount, 1)
            XCTAssertEqual(remote.executeCallCount, 1)
            XCTAssertEqual(Set(reactor.currentState.assessments.map(\.source)), [.onDevice, .server])
        }
    }

    func test_한쪽_실패가_다른쪽_결과를_취소하지_않는다() {
        let onDeviceAssessment = QualityAssessment.fixture(source: .onDevice, topGradeName: "정상")
        let (reactor, _, _) = given("서버는 실패하고 온디바이스는 성공한다") {
            makeSUT(onDevice: .just(onDeviceAssessment),
                    remote: .error(QualityInspectionError.networkUnavailable))
        }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("온디바이스 판정은 남고 실패만 별도로 전달된다") {
            XCTAssertEqual(reactor.currentState.assessments, [onDeviceAssessment])
            XCTAssertEqual(reactor.currentState.failure, .networkUnavailable)
        }
    }

    func test_양쪽이_모두_실패하면_판정이_비어_있다() {
        let (reactor, _, _) = given("두 판별이 모두 실패한다") {
            makeSUT(onDevice: .error(QualityInspectionError.classificationModelUnavailable),
                    remote: .error(QualityInspectionError.networkUnavailable))
        }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("판정은 비어 있고 크래시하지 않는다") {
            XCTAssertTrue(reactor.currentState.assessments.isEmpty)
            XCTAssertNotNil(reactor.currentState.failure)
        }
    }

    func test_같은_출처의_판정은_중복으로_쌓이지_않는다() {
        let (reactor, _, _) = given("두 판별이 준비되어 있다") { makeSUT() }

        when("viewDidLoad를 두 번 보낸다") {
            reactor.action.onNext(.viewDidLoad)
            reactor.action.onNext(.viewDidLoad)
        }

        then("출처별로 하나씩만 유지된다") {
            XCTAssertEqual(reactor.currentState.assessments.count, 2)
        }
    }

    func test_시트가_large가_되면_더보기_버튼이_보인다() {
        let (reactor, _, _) = given("결과 화면이 medium으로 떠 있다") { makeSUT() }

        when("detent가 large로 바뀐다") {
            reactor.action.onNext(.detentChanged(.large))
        }

        then("더보기 버튼이 보이는 상태다") {
            XCTAssertTrue(reactor.currentState.isMoreInfoVisible)
        }
    }

    func test_시트가_medium으로_돌아가면_더보기_버튼이_숨는다() {
        let (reactor, _, _) = given("large 상태다") { makeSUT() }
        reactor.action.onNext(.detentChanged(.large))

        when("detent가 medium으로 바뀐다") {
            reactor.action.onNext(.detentChanged(.medium))
        }

        then("더보기 버튼이 숨은 상태다") {
            XCTAssertFalse(reactor.currentState.isMoreInfoVisible)
        }
    }

    func test_더보기를_누르면_누적된_판정으로_차트를_요청한다() {
        let (reactor, _, _) = given("두 판정이 누적되어 있다") { makeSUT() }
        reactor.action.onNext(.viewDidLoad)

        when("더보기 버튼 액션을 보낸다") {
            reactor.action.onNext(.moreInfoButtonTapped)
        }

        then("두 판정이 차트 요청으로 전달된다") {
            XCTAssertEqual(reactor.currentState.chartRequest?.count, 2)
        }
    }
}
