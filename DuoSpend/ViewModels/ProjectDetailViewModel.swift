import Foundation
import SwiftData

/// ViewModel pour l'écran de détail d'un projet
@Observable
class ProjectDetailViewModel {
    let project: Project

    var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }

    init(project: Project) {
        self.project = project
    }
}
