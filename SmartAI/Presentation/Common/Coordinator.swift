protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }

    func start()
}

extension Coordinator {
    func add(child coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func remove(child coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
