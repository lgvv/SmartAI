import XCTest
import RxSwift
@testable import SmartAI

final class CameraReactorTests: XCTestCase {
    func test_화면이_뜨면_세션을_시작한다() {
        let useCase = given("카메라 세션 유즈케이스가 준비되어 있다") {
            StubCameraSessionUseCase()
        }
        let reactor = CameraReactor(cameraSession: useCase)

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("세션이 한 번 시작된다") {
            XCTAssertEqual(useCase.startCallCount, 1)
            XCTAssertNil(reactor.currentState.failure)
        }
    }

    func test_세션_시작이_실패하면_실패_펄스를_발행한다() {
        let reactor = given("카메라를 쓸 수 없는 기기다") {
            CameraReactor(cameraSession: StubCameraSessionUseCase(
                startResult: .error(CameraError.captureDeviceUnavailable)
            ))
        }

        when("viewDidLoad 액션을 보낸다") {
            reactor.action.onNext(.viewDidLoad)
        }

        then("captureDeviceUnavailable이 전달된다") {
            XCTAssertEqual(reactor.currentState.failure, .captureDeviceUnavailable)
        }
    }

    func test_촬영_버튼을_누르면_사진_펄스를_발행한다() {
        let photo = CapturedPhoto.fixture(data: Data([0x01, 0x02]), orientation: .right)
        let reactor = given("촬영이 성공하는 세션이다") {
            CameraReactor(cameraSession: StubCameraSessionUseCase(captureResult: .just(photo)))
        }

        when("촬영 버튼 액션을 보낸다") {
            reactor.action.onNext(.captureButtonTapped)
        }

        then("촬영된 사진이 전달되고 촬영 상태가 해제된다") {
            XCTAssertEqual(reactor.currentState.capturedPhoto, photo)
            XCTAssertFalse(reactor.currentState.isCapturing)
        }
    }

    func test_촬영이_실패하면_실패_펄스를_발행한다() {
        let reactor = given("세션이 구성되지 않은 상태다") {
            CameraReactor(cameraSession: StubCameraSessionUseCase(
                captureResult: .error(CameraError.sessionNotConfigured)
            ))
        }

        when("촬영 버튼 액션을 보낸다") {
            reactor.action.onNext(.captureButtonTapped)
        }

        then("sessionNotConfigured가 전달되고 크래시하지 않는다") {
            XCTAssertEqual(reactor.currentState.failure, .sessionNotConfigured)
            XCTAssertNil(reactor.currentState.capturedPhoto)
        }
    }

    func test_촬영_중에는_추가_촬영을_받지_않는다() {
        let useCase = given("촬영이 끝나지 않는 세션이다") {
            StubCameraSessionUseCase(captureResult: .never())
        }
        let reactor = CameraReactor(cameraSession: useCase)

        when("촬영 버튼을 두 번 누른다") {
            reactor.action.onNext(.captureButtonTapped)
            reactor.action.onNext(.captureButtonTapped)
        }

        then("촬영 요청은 한 번만 전달된다") {
            XCTAssertEqual(useCase.captureCallCount, 1)
            XCTAssertTrue(reactor.currentState.isCapturing)
        }
    }

    func test_화면이_사라지면_세션을_정지한다() {
        let useCase = given("실행 중인 세션이 있다") {
            StubCameraSessionUseCase()
        }
        let reactor = CameraReactor(cameraSession: useCase)

        when("viewWillDisappear 액션을 보낸다") {
            reactor.action.onNext(.viewWillDisappear)
        }

        then("세션이 정지된다") {
            XCTAssertEqual(useCase.stopCallCount, 1)
        }
    }
}
