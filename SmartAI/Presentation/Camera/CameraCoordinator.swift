import UIKit

protocol CameraCoordinatorDelegate: AnyObject {
    func cameraCoordinator(_ coordinator: CameraCoordinator, didCapture photo: CapturedPhoto)
}

final class CameraCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var delegate: CameraCoordinatorDelegate?

    private let navigationController: UINavigationController
    private let makeCameraViewController: () -> CameraViewController

    init(navigationController: UINavigationController,
         makeCameraViewController: @escaping () -> CameraViewController) {
        self.navigationController = navigationController
        self.makeCameraViewController = makeCameraViewController
    }

    func start() {
        let viewController = makeCameraViewController()
        viewController.delegate = self

        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension CameraCoordinator: CameraViewControllerDelegate {
    func cameraViewController(_ viewController: CameraViewController, didCapture photo: CapturedPhoto) {
        delegate?.cameraCoordinator(self, didCapture: photo)
    }
}
