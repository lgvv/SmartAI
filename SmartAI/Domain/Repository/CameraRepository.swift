import RxSwift

protocol CameraRepository {
    func startSession() -> Completable
    func stopSession()
    func capturePhoto() -> Single<CapturedPhoto>
}
