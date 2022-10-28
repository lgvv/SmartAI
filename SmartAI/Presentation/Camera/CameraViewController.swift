import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol CameraViewControllerDelegate: AnyObject {
    func cameraViewController(_ viewController: CameraViewController, didCapture photo: CapturedPhoto)
}

final class CameraViewController: UIViewController, View {
    typealias Reactor = CameraReactor

    private enum Metric {
        static let captureButtonBottomInset: CGFloat = 100
        static let captureButtonFontSize: CGFloat = 22
    }

    weak var delegate: CameraViewControllerDelegate?
    var disposeBag = DisposeBag()

    private let previewView: CameraPreviewView

    private let captureButton: UIButton = {
        let title = "🤖 분석 시작하기 🤖"
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(.font,
                                     value: UIFont.pretendard(.semiBold, size: Metric.captureButtonFontSize),
                                     range: NSRange(location: 0, length: (title as NSString).length))

        let button = UIButton()
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.green, for: .normal)
        return button
    }()

    init(previewView: CameraPreviewView) {
        self.previewView = previewView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        reactor?.action.onNext(.viewDidLoad)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        reactor?.action.onNext(.viewWillDisappear)
    }

    func bind(reactor: CameraReactor) {
        captureButton.rx.tap
            .map { Reactor.Action.captureButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.pulse(\.$capturedPhoto)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind { owner, photo in
                owner.delegate?.cameraViewController(owner, didCapture: photo)
            }
            .disposed(by: disposeBag)
    }

    private func configureHierarchy() {
        view.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        view.addSubview(captureButton)
        captureButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(Metric.captureButtonBottomInset)
            $0.centerX.equalToSuperview()
        }
    }
}
