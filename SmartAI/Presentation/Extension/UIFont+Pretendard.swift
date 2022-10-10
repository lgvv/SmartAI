import UIKit

extension UIFont {
    enum Pretendard: String, CaseIterable {
        case light = "Pretendard-Light"
        case regular = "Pretendard-Regular"
        case medium = "Pretendard-Medium"
        case semiBold = "Pretendard-SemiBold"
        case bold = "Pretendard-Bold"
        case extraBold = "Pretendard-ExtraBold"
    }

    static func pretendard(_ style: Pretendard, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            assertionFailure("\(style.rawValue) 폰트가 번들에 등록되지 않았습니다")
            return .systemFont(ofSize: size)
        }

        return font
    }
}
