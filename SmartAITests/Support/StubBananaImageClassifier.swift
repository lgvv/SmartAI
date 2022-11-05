import RxSwift
@testable import SmartAI

final class StubBananaImageClassifier: BananaImageClassifying {
    private let result: Single<[BananaGrade]>
    private(set) var classifyCallCount = 0

    init(result: Single<[BananaGrade]> = .just([.fixture()])) {
        self.result = result
    }

    func classify(photo: CapturedPhoto) -> Single<[BananaGrade]> {
        classifyCallCount += 1
        return result
    }
}
