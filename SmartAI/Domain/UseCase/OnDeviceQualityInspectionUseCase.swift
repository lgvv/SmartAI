import RxSwift

protocol OnDeviceQualityInspectionUseCase {
    func execute(photo: CapturedPhoto) -> Single<QualityAssessment>
}
