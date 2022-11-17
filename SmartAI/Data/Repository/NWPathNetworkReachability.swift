import Foundation
import Network

final class NWPathNetworkReachability: NetworkReachability {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.smartai.network.reachability")
    private let lock = NSLock()

    private var isPathSatisfied = false

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }

        return isPathSatisfied
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            self.lock.lock()
            self.isPathSatisfied = path.status == .satisfied
            self.lock.unlock()
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }
}
