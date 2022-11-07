import RxSwift
@testable import SmartAI

final class StubOnDeviceQualityInspectionUseCase: OnDeviceQualityInspectionUseCase {
    private let result: Single<QualityAssessment>
    private(set) var executeCallCount = 0

    init(result: Single<QualityAssessment> = .just(.fixture())) {
        self.result = result
    }

    func execute(photo: CapturedPhoto) -> Single<QualityAssessment> {
        executeCallCount += 1
        return result
    }
}
