import RxSwift

protocol CameraSessionUseCase {
    func start() -> Completable
    func stop()
    func capture() -> Single<CapturedPhoto>
}
