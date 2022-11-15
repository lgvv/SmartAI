import RxSwift
@testable import SmartAI

final class StubBananaQualityAPIClient: BananaQualityAPIClient {
    private let result: Single<BananaResponseDTO>
    private(set) var uploadCallCount = 0

    init(result: Single<BananaResponseDTO>) {
        self.result = result
    }

    func uploadPhoto(_ photo: CapturedPhoto) -> Single<BananaResponseDTO> {
        uploadCallCount += 1
        return result
    }
}
