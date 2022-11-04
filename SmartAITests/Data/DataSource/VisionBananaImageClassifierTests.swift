import XCTest
import RxBlocking
@testable import SmartAI

final class VisionBananaImageClassifierTests: XCTestCase {
    func test_디코딩할_수_없는_사진은_undecodablePhoto로_실패한다() {
        let photo = given("이미지가 아닌 데이터를 담은 사진이다") {
            CapturedPhoto(data: Data([0x00, 0x01, 0x02]), orientation: .up)
        }

        let result = when("분류를 실행한다") {
            VisionBananaImageClassifier().classify(photo: photo).toBlocking(timeout: 10).materialize()
        }

        then("undecodablePhoto로 실패하고 크래시하지 않는다") {
            guard case let .failed(_, error) = result else {
                return XCTFail("실패하지 않았습니다")
            }
            XCTAssertEqual(error as? QualityInspectionError, .undecodablePhoto)
        }
    }
}
