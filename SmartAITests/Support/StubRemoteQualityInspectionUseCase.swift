import RxSwift
@testable import SmartAI

final class StubRemoteQualityInspectionUseCase: RemoteQualityInspectionUseCase {
    private let result: Single<QualityAssessment>
    private(set) var executeCallCount = 0

    init(result: Single<QualityAssessment> = .just(.fixture(source: .server))) {
        self.result = result
    }

    func execute(photo: CapturedPhoto) -> Single<QualityAssessment> {
        executeCallCount += 1
        return result
    }
}
