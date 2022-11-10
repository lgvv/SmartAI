import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let dependency: AppDependency

    init(navigationController: UINavigationController, dependency: AppDependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    func start() {
        showCamera()
    }

    private func showCamera() {
        let coordinator = CameraCoordinator(navigationController: navigationController,
                                            makeCameraViewController: dependency.makeCameraViewController)
        coordinator.delegate = self
        add(child: coordinator)
        coordinator.start()
    }

    private func showResult(photo: CapturedPhoto) {
        guard let presentingViewController = navigationController.viewControllers.first else { return }

        let coordinator = ResultCoordinator(presentingViewController: presentingViewController,
                                            photo: photo,
                                            makeResultViewController: dependency.makeResultViewController)
        add(child: coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: CameraCoordinatorDelegate {
    func cameraCoordinator(_ coordinator: CameraCoordinator, didCapture photo: CapturedPhoto) {
        showResult(photo: photo)
    }
}
