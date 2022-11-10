import UIKit

final class ResultCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let presentingViewController: UIViewController
    private let photo: CapturedPhoto
    private let makeResultViewController: (CapturedPhoto) -> ResultViewController

    private weak var navigationController: UINavigationController?

    init(presentingViewController: UIViewController,
         photo: CapturedPhoto,
         makeResultViewController: @escaping (CapturedPhoto) -> ResultViewController) {
        self.presentingViewController = presentingViewController
        self.photo = photo
        self.makeResultViewController = makeResultViewController
    }

    func start() {
        let viewController = makeResultViewController(photo)
        viewController.delegate = self

        let navigationController = UINavigationController(rootViewController: viewController)
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.delegate = viewController
        }

        presentingViewController.present(navigationController, animated: true)
        self.navigationController = navigationController
    }
}

extension ResultCoordinator: ResultViewControllerDelegate {
    func resultViewController(_ viewController: ResultViewController,
                             didRequestChartFor assessments: [QualityAssessment]) {
        guard let navigationController else { return }

        let coordinator = ChartCoordinator(navigationController: navigationController,
                                           assessments: assessments)
        add(child: coordinator)
        coordinator.start()
    }
}
