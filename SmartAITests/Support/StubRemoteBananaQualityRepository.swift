import RxSwift
@testable import SmartAI

final class StubRemoteBananaQualityRepository: RemoteBananaQualityRepository {
    private let result: Single<QualityAssessment>
    private(set) var assessCallCount = 0

    init(result: Single<QualityAssessment> = .just(.fixture(source: .server))) {
        self.result = result
    }

    func assess(photo: CapturedPhoto) -> Single<QualityAssessment> {
        assessCallCount += 1
        return result
    }
}
