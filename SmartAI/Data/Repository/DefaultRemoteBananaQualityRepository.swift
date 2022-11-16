import RxSwift

final class DefaultRemoteBananaQualityRepository: RemoteBananaQualityRepository {
    private let apiClient: BananaQualityAPIClient

    init(apiClient: BananaQualityAPIClient) {
        self.apiClient = apiClient
    }

    func assess(photo: CapturedPhoto) -> Single<QualityAssessment> {
        apiClient.uploadPhoto(photo).map { $0.toDomain() }
    }
}
