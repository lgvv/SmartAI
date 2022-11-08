import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit

protocol ResultViewControllerDelegate: AnyObject {
    func resultViewController(_ viewController: ResultViewController,
                             didRequestChartFor assessments: [QualityAssessment])
}

final class ResultViewController: UIViewController, View {
    typealias Reactor = ResultReactor

    private enum Metric {
        static let imageInset: CGFloat = 20
        static let buttonInset: CGFloat = 40
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 4
        static let answerFontSize: CGFloat = 16
        static let mainFontSize: CGFloat = 20
        static let subFontSize: CGFloat = 12
        static let fadeDuration: TimeInterval = 0.3
    }

    private enum Text {
        static let main = "더 자세한 결과 확인하기 👉"
        static let sub = "📡 서버 통신이 원활한 경우에만 확인하실 수 있습니다."
    }

    weak var delegate: ResultViewControllerDelegate?
    var disposeBag = DisposeBag()

    private let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metric.cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.textAlignment = .center
        label.font = .pretendard(.regular, size: Metric.answerFontSize)
        return label
    }()

    private let moreInfoButton: UIButton = {
        let text = """
        \(Text.main)

        \(Text.sub)
        """

        let attributedTitle = NSMutableAttributedString(string: text)
        attributedTitle.addAttribute(.font,
                                     value: UIFont.pretendard(.bold, size: Metric.mainFontSize),
                                     range: (text as NSString).range(of: Text.main))
        attributedTitle.addAttribute(.font,
                                     value: UIFont.pretendard(.regular, size: Metric.subFontSize),
                                     range: (text as NSString).range(of: Text.sub))

        let button = UIButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.setTitleColor(.black, for: .normal)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.layer.backgroundColor = UIColor.green.cgColor
        button.layer.borderWidth = Metric.borderWidth
        button.layer.cornerRadius = Metric.cornerRadius
        button.alpha = 0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configureHierarchy()
        reactor?.action.onNext(.viewDidLoad)
    }

    func bind(reactor: ResultReactor) {
        resultImageView.image = UIImage(data: reactor.currentState.photo.data)

        moreInfoButton.rx.tap
            .map { Reactor.Action.moreInfoButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map(\.topGradeName)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: answerLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map(\.isMoreInfoVisible)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind { owner, isVisible in
                UIView.animate(withDuration: Metric.fadeDuration) {
                    owner.moreInfoButton.alpha = isVisible ? 1 : 0
                }
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$chartRequest)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .bind { owner, assessments in
                owner.delegate?.resultViewController(owner, didRequestChartFor: assessments)
            }
            .disposed(by: disposeBag)
    }

    private func configureHierarchy() {
        view.addSubview(moreInfoButton)
        moreInfoButton.snp.makeConstraints {
            $0.top.equalTo(view.snp.centerY).offset(Metric.buttonInset)
            $0.leading.trailing.equalToSuperview().inset(Metric.buttonInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(resultImageView)
        resultImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(Metric.imageInset)
            $0.height.equalTo(resultImageView.snp.width)
        }

        resultImageView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

extension ResultViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(
        _ sheetPresentationController: UISheetPresentationController
    ) {
        guard let identifier = sheetPresentationController.selectedDetentIdentifier else { return }

        switch identifier {
        case .medium:
            reactor?.action.onNext(.detentChanged(.medium))
        case .large:
            reactor?.action.onNext(.detentChanged(.large))
        default:
            break
        }
    }
}
