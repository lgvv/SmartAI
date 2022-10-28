import XCTest
import AVFoundation
@testable import SmartAI

final class CameraViewControllerTests: XCTestCase {
    private func makeSUT() -> CameraViewController {
        let viewController = CameraViewController(previewView: CameraPreviewView(session: AVCaptureSession()))
        viewController.reactor = CameraReactor(cameraSession: StubCameraSessionUseCase())
        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 402, height: 874)
        viewController.view.layoutIfNeeded()
        return viewController
    }

    private func buttons(in view: UIView) -> [UIButton] {
        view.subviews.flatMap { subview -> [UIButton] in
            let nested = buttons(in: subview)
            return (subview as? UIButton).map { [$0] + nested } ?? nested
        }
    }

    func test_촬영_버튼은_화면에_하나만_존재한다() {
        let sut = given("카메라 화면을 구성한다") { makeSUT() }

        let captureButtons = when("버튼을 모두 찾는다") { buttons(in: sut.view) }

        then("촬영 버튼이 정확히 하나다") {
            XCTAssertEqual(captureButtons.count, 1)
            XCTAssertEqual(captureButtons.first?.attributedTitle(for: .normal)?.string,
                           "🤖 분석 시작하기 🤖")
        }
    }

    func test_촬영_버튼은_Pretendard_SemiBold_22포인트다() {
        let sut = given("카메라 화면을 구성한다") { makeSUT() }

        let title = when("버튼의 속성 문자열을 읽는다") {
            buttons(in: sut.view).first?.attributedTitle(for: .normal)
        }

        then("폰트가 Pretendard SemiBold 22포인트다") {
            let font = title?.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            XCTAssertEqual(font?.fontName, "Pretendard-SemiBold")
            XCTAssertEqual(font?.pointSize, 22)
        }
    }

    func test_프리뷰는_화면_전체를_채우고_버튼은_하단에서_100포인트_위에_있다() {
        let sut = given("402x874 크기로 배치한다") { makeSUT() }

        then("프리뷰가 전체를 덮고 버튼 하단이 774포인트다") {
            let preview = sut.view.subviews.first { $0 is CameraPreviewView }
            XCTAssertEqual(preview?.frame, CGRect(x: 0, y: 0, width: 402, height: 874))

            let button = buttons(in: sut.view).first
            XCTAssertEqual(button?.frame.maxY, 774)
            XCTAssertEqual(button?.center.x, 201)
        }
    }
}
