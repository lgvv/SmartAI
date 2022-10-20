import RxSwift

final class DefaultOnDeviceQualityInspectionUseCase: OnDeviceQualityInspectionUseCase {
    static let displayedGradeCount = 4

    private let repository: OnDeviceBananaQualityRepository

    init(repository: OnDeviceBananaQualityRepository) {
        self.repository = repository
    }

    func execute(photo: CapturedPhoto) -> Single<QualityAssessment> {
        repository.assess(photo: photo)
            .map { $0.prefixed(by: Self.displayedGradeCount) }
    }
}
