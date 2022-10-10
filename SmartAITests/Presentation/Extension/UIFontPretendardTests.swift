import XCTest
@testable import SmartAI

final class UIFontPretendardTests: XCTestCase {
    func test_모든_스타일이_번들_폰트로_해석된다() {
        let styles = given("선언된 모든 Pretendard 스타일을 가져온다") {
            UIFont.Pretendard.allCases
        }

        then("어떤 스타일도 시스템 폰트로 대체되지 않는다") {
            for style in styles {
                let font = UIFont.pretendard(style, size: 16)
                XCTAssertEqual(font.fontName, style.rawValue, "\(style.rawValue)가 번들에 없습니다")
            }
        }
    }

    func test_요청한_크기가_그대로_적용된다() {
        let font = when("22포인트로 요청한다") {
            UIFont.pretendard(.semiBold, size: 22)
        }

        then("크기가 22포인트다") {
            XCTAssertEqual(font.pointSize, 22)
        }
    }
}
