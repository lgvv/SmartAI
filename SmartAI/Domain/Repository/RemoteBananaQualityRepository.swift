import RxSwift

protocol RemoteBananaQualityRepository {
    func assess(photo: CapturedPhoto) -> Single<QualityAssessment>
}
