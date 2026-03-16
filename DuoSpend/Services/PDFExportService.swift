import UIKit
import Foundation

/// Génère un PDF récapitulatif d'un projet DuoSpend.
/// Utilise UIGraphicsPDFRenderer — aucune dépendance externe.
@MainActor
enum PDFExportService {

    // MARK: - Couleurs (hex hardcodés pour UIKit)
    private static let colorAccent  = UIColor(red: 0.42, green: 0.39, blue: 1.00, alpha: 1) // #6C63FF
    private static let colorP1      = UIColor(red: 0.18, green: 0.50, blue: 0.95, alpha: 1) // #2E80F2
    private static let colorP2      = UIColor(red: 0.95, green: 0.35, blue: 0.49, alpha: 1) // #F25A7E
    private static let colorGray    = UIColor.secondaryLabel
    private static let colorBg      = UIColor.systemBackground
    private static let colorCard    = UIColor.secondarySystemGroupedBackground
    private static let colorSep     = UIColor.separator

    // MARK: - Dimensions
    private static let pageW: CGFloat = 595
    private static let pageH: CGFloat = 842
    private static let margin: CGFloat = 48
    private static var contentW: CGFloat { pageW - margin * 2 }

    // MARK: - Fonts
    private static func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let desc = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: desc, size: size)
    }

    // MARK: - Entry point

    /// Génère le PDF et retourne l'URL du fichier temporaire.
    static func generatePDF(project: Project, expenses: [Expense], balance: BalanceResult) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: pageW, height: pageH)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let sorted = expenses.sorted { $0.date > $1.date }

        let data = renderer.pdfData { ctx in
            var y: CGFloat = margin
            var page = 1
            var totalPages = 1 + Int(ceil(Double(max(sorted.count - 10, 0)) / 18.0))

            ctx.beginPage()
            colorBg.setFill()
            UIRectFill(pageRect)

            y = drawHeader(project: project, balance: balance, y: y)
            y = drawBalance(balance: balance, partner1: project.partner1Name, partner2: project.partner2Name, y: y)
            y = drawStats(balance: balance, partner1: project.partner1Name, partner2: project.partner2Name,
                          expenses: sorted, y: y)
            y = drawExpensesHeader(y: y)

            for (i, expense) in sorted.enumerated() {
                if y > pageH - margin - 60 {
                    drawFooter(page: page, total: totalPages)
                    ctx.beginPage()
                    colorBg.setFill()
                    UIRectFill(pageRect)
                    y = margin
                    page += 1
                    y = drawExpensesHeader(y: y)
                }
                y = drawExpenseRow(expense: expense,
                                   partner1: project.partner1Name,
                                   partner2: project.partner2Name,
                                   y: y,
                                   isLast: i == sorted.count - 1)
            }

            drawFooter(page: page, total: max(page, totalPages))
        }

        let safeName = project.name.replacingOccurrences(of: "/", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DuoSpend_\(safeName).pdf")
        try data.write(to: url)
        return url
    }
