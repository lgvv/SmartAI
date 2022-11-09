import SwiftUI
import UIKit

final class ChartCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let assessments: [QualityAssessment]

    init(navigationController: UINavigationController, assessments: [QualityAssessment]) {
        self.navigationController = navigationController
        self.assessments = assessments
    }

    func start() {
        let viewController = UIHostingController(rootView: ChartView(assessments: assessments))
        navigationController.pushViewController(viewController, animated: true)
    }
}
