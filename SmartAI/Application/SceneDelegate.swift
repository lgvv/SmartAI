import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let coordinator = AppCoordinator(navigationController: navigationController,
                                         dependency: AppDependency())
        coordinator.start()

        self.window = window
        self.appCoordinator = coordinator
    }
}
