import RxSwift
@testable import SmartAI

final class StubCameraSessionUseCase: CameraSessionUseCase {
    private let startResult: Completable
    private let captureResult: Single<CapturedPhoto>

    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0
    private(set) var captureCallCount = 0

    init(startResult: Completable = .empty(),
         captureResult: Single<CapturedPhoto> = .just(.fixture())) {
        self.startResult = startResult
        self.captureResult = captureResult
    }

    func start() -> Completable {
        startCallCount += 1
        return startResult
    }

    func stop() {
        stopCallCount += 1
    }

    func capture() -> Single<CapturedPhoto> {
        captureCallCount += 1
        return captureResult
    }
}
