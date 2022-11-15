import RxSwift

protocol BananaQualityAPIClient {
    func uploadPhoto(_ photo: CapturedPhoto) -> Single<BananaResponseDTO>
}
