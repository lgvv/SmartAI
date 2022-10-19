import RxSwift

final class DefaultRemoteQualityInspectionUseCase: RemoteQualityInspectionUseCase {
    private let repository: RemoteBananaQualityRepository
    private let reachability: NetworkReachability

    init(repository: RemoteBananaQualityRepository, reachability: NetworkReachability) {
        self.repository = repository
        self.reachability = reachability
    }

    func execute(photo: CapturedPhoto) -> Single<QualityAssessment> {
        Single.deferred { [repository, reachability] in
            guard reachability.isConnected else {
                return .error(QualityInspectionError.networkUnavailable)
            }

            return repository.assess(photo: photo)
        }
    }
}
