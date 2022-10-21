import RxSwift

final class DefaultCameraSessionUseCase: CameraSessionUseCase {
    private let repository: CameraRepository

    init(repository: CameraRepository) {
        self.repository = repository
    }

    func start() -> Completable {
        repository.startSession()
    }

    func stop() {
        repository.stopSession()
    }

    func capture() -> Single<CapturedPhoto> {
        repository.capturePhoto()
    }
}
