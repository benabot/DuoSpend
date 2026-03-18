import Foundation
import SwiftData
import os

/// Service de fusion entre un SyncPayload reçu et les données SwiftData locales.
/// Logique pure, testable unitairement sans MultipeerConnectivity.
struct SyncMergeService {

    private static let logger = Logger(subsystem: "fr.benabot.DuoSpend", category: "SyncMerge")

    /// Fusionne un payload reçu dans le contexte SwiftData local.
    /// - Parameters:
    ///   - payload: Données reçues du peer.
    ///   - context: ModelContext SwiftData cible.
    /// - Returns: Nombre de nouvelles dépenses ajoutées.
    @discardableResult
    static func merge(payload: SyncPayload, into context: ModelContext) throws -> Int {
        let existingProject = findMatchingProject(payload: payload, in: context)

        if let project = existingProject {
            logger.info("Projet existant trouvé : \(project.name). Fusion des dépenses.")
            return mergeExpenses(from: payload, into: project, context: context)
        } else {
            logger.info("Aucun projet correspondant. Création de \(payload.projectName).")
            return createProject(from: payload, in: context)
        }
    }

    // MARK: - Private

    /// Recherche un projet local correspondant au payload (même nom + mêmes partenaires).
    private static func findMatchingProject(payload: SyncPayload, in context: ModelContext) -> Project? {
        let name = payload.projectName
        let p1 = payload.partner1Name
        let p2 = payload.partner2Name

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate<Project> {
                $0.name == name && $0.partner1Name == p1 && $0.partner2Name == p2
            }
        )

        return try? context.fetch(descriptor).first
    }

    /// Fusionne les dépenses du payload dans un projet existant, en dédoublonnant.
    private static func mergeExpenses(from payload: SyncPayload, into project: Project, context: ModelContext) -> Int {
        let existingExpenses = project.expenses
        var addedCount = 0

        for syncExpense in payload.expenses {
            guard !isDuplicate(syncExpense, in: existingExpenses) else {
                logger.debug("Doublon ignoré : \(syncExpense.title) — \(syncExpense.amount)")
                continue
            }

            let expense = Expense(
                title: syncExpense.title,
                amount: syncExpense.amount,
                paidBy: syncExpense.paidBy,
                splitRatio: syncExpense.splitRatio,
                category: syncExpense.category,
                date: syncExpense.date
            )
            expense.project = project
            context.insert(expense)
            addedCount += 1
        }

        logger.info("\(addedCount) nouvelles dépenses ajoutées au projet \(project.name).")
        return addedCount
    }

    /// Crée un nouveau projet + toutes ses dépenses à partir du payload.
    private static func createProject(from payload: SyncPayload, in context: ModelContext) -> Int {
        let project = Project(
            name: payload.projectName,
            emoji: payload.projectEmoji,
            budget: payload.projectBudget,
            partner1Name: payload.partner1Name,
            partner2Name: payload.partner2Name,
            createdAt: payload.projectCreatedAt
        )
        context.insert(project)

        for syncExpense in payload.expenses {
            let expense = Expense(
                title: syncExpense.title,
                amount: syncExpense.amount,
                paidBy: syncExpense.paidBy,
                splitRatio: syncExpense.splitRatio,
                category: syncExpense.category,
                date: syncExpense.date
            )
            expense.project = project
            context.insert(expense)
        }

        return payload.expenses.count
    }

    /// Vérifie si une dépense est un doublon (même title + même amount + même date à la seconde).
    private static func isDuplicate(_ syncExpense: SyncExpense, in existingExpenses: [Expense]) -> Bool {
        existingExpenses.contains { existing in
            existing.title == syncExpense.title
                && existing.amount == syncExpense.amount
                && Calendar.current.isDate(existing.date, equalTo: syncExpense.date, toGranularity: .second)
        }
    }
}
