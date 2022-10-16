import RxSwift

protocol RemoteQualityInspectionUseCase {
    func execute(photo: CapturedPhoto) -> Single<QualityAssessment>
}
