import RxSwift

protocol OnDeviceBananaQualityRepository {
    func assess(photo: CapturedPhoto) -> Single<QualityAssessment>
}
