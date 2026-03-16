import UIKit
import Foundation

/// Génère un PDF récapitulatif d'un projet (balance, stats, dépenses).
/// Utilise UIGraphicsPDFRenderer — aucune dépendance externe.
@MainActor
enum PDFExportService {

    // MARK: - Constantes layout (A4 : 595 × 842 pt)

    private static let pageW: CGFloat = 595
    private static let pageH: CGFloat = 842
    private static let margin: CGFloat = 48
    private static var contentW: CGFloat { pageW - margin * 2 }
    private static let footerReserve: CGFloat = 40
    /// Y maximum avant page break
    private static var maxY: CGFloat { pageH - margin - footerReserve }

    // MARK: - Couleurs

    private static let accentColor = UIColor(red: 0x6C / 255, green: 0x63 / 255, blue: 0xFF / 255, alpha: 1)
    private static let p1Color = UIColor(red: 0x2E / 255, green: 0x80 / 255, blue: 0xF2 / 255, alpha: 1)
    private static let p2Color = UIColor(red: 0xF2 / 255, green: 0x5A / 255, blue: 0x7E / 255, alpha: 1)
    private static let grayLight = UIColor(white: 0.88, alpha: 1)
    private static let grayText = UIColor(white: 0.4, alpha: 1)

    // MARK: - Police arrondie

    private static func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let desc = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: desc, size: size)
    }

    // MARK: - API publique

    /// Génère le PDF et retourne l'URL du fichier temporaire
    static func generatePDF(
        project: Project,
        expenses: [Expense],
        balance: BalanceResult
    ) throws -> URL {
        let sorted = expenses.sorted { $0.date > $1.date }
        let p1Count = expenses.filter { $0.paidBy == .partner1 }.count
        let p2Count = expenses.count - p1Count
        let pageRect = CGRect(x: 0, y: 0, width: pageW, height: pageH)

        // Première passe : compter les pages
        let totalPages = countPages(
            project: project, sorted: sorted, balance: balance,
            p1Count: p1Count, p2Count: p2Count
        )

        // Deuxième passe : dessiner avec numéros de page corrects
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        var page = 1

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y = margin

            y = drawHeader(project: project, balance: balance, y: y)
            y = drawSeparator(y: y)
            y = drawBalance(
                balance: balance,
                p1Name: project.partner1Name,
                p2Name: project.partner2Name,
                y: y
            )
            y = drawStats(
                balance: balance,
                p1Name: project.partner1Name, p2Name: project.partner2Name,
                p1Count: p1Count, p2Count: p2Count,
                y: y
            )

            // Section dépenses
            if !sorted.isEmpty {
                y = ensureSpace(28, y: y, page: &page, total: totalPages, ctx: ctx)
                drawSectionTitle("Depenses", y: y)
                y += 28

                let rowH: CGFloat = 36
                for (i, expense) in sorted.enumerated() {
                    y = ensureSpace(rowH, y: y, page: &page, total: totalPages, ctx: ctx)
                    drawExpenseRow(
                        expense: expense,
                        p1Name: project.partner1Name,
                        p2Name: project.partner2Name,
                        y: y
                    )
                    y += rowH

                    if i < sorted.count - 1 {
                        drawThinSeparator(y: y, indentLeft: 32)
                    }
                }
            }

            drawFooter(page: page, total: totalPages)
        }

        let safeName = project.name
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("DuoSpend_\(safeName).pdf")
        try data.write(to: url)
        return url
    }

    // MARK: - Comptage de pages (dry run)

    private static func countPages(
        project: Project, sorted: [Expense], balance: BalanceResult,
        p1Count: Int, p2Count: Int
    ) -> Int {
        var y = margin
        var pages = 1

        // Header ~110pt + sep ~16pt + balance ~72pt + stats ~86pt
        let headerBlock: CGFloat = (project.budget > 0) ? 130 : 96
        y += headerBlock + 16 + 72 + 86

        guard !sorted.isEmpty else { return 1 }

        // Titre section
        if y + 28 > maxY { pages += 1; y = margin }
        y += 28

        // Lignes
        let rowH: CGFloat = 36
        for _ in sorted {
            if y + rowH > maxY { pages += 1; y = margin }
            y += rowH
        }
        return pages
    }

    // MARK: - Page break helper

    private static func ensureSpace(
        _ needed: CGFloat,
        y: CGFloat,
        page: inout Int,
        total: Int,
        ctx: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        guard y + needed > maxY else { return y }
        drawFooter(page: page, total: total)
        ctx.beginPage()
        page += 1
        return margin
    }

    // MARK: - En-tête

    private static func drawHeader(project: Project, balance: BalanceResult, y: CGFloat) -> CGFloat {
        var cy = y

        // Emoji + titre
        let emojiAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 36)]
        let titleAttr: [NSAttributedString.Key: Any] = [
            .font: font(24, weight: .bold),
            .foregroundColor: UIColor.black,
        ]
        let emoji = project.emoji as NSString
        let emojiW = emoji.size(withAttributes: emojiAttr).width
        emoji.draw(at: CGPoint(x: margin, y: cy), withAttributes: emojiAttr)
        (project.name.uppercased() as NSString).draw(
            at: CGPoint(x: margin + emojiW + 8, y: cy + 6),
            withAttributes: titleAttr
        )
        cy += 44

        // Sous-titre partenaires
        let subAttr: [NSAttributedString.Key: Any] = [
            .font: font(16), .foregroundColor: grayText,
        ]
        ("\(project.partner1Name) & \(project.partner2Name)" as NSString)
            .draw(at: CGPoint(x: margin, y: cy), withAttributes: subAttr)
        cy += 22

        // Date création
        let dateAttr: [NSAttributedString.Key: Any] = [
            .font: font(12), .foregroundColor: grayText,
        ]
        ("Cree le \(project.createdAt.formatted(date: .abbreviated, time: .omitted))" as NSString)
            .draw(at: CGPoint(x: margin, y: cy), withAttributes: dateAttr)
        cy += 22

        // Barre budget
        if project.budget > 0 {
            let spent = Double(truncating: balance.totalSpent as NSDecimalNumber)
            let budget = Double(truncating: project.budget as NSDecimalNumber)
            let frac = min(spent / budget, 1.0)

            // Track gris
            let bar = CGRect(x: margin, y: cy, width: contentW, height: 10)
            UIBezierPath(roundedRect: bar, cornerRadius: 5).fill(with: .normal, alpha: 1)
            UIColor(white: 0.92, alpha: 1).setFill()
            UIBezierPath(roundedRect: bar, cornerRadius: 5).fill()

            // Remplissage
            if frac > 0 {
                let fill = CGRect(x: margin, y: cy, width: contentW * frac, height: 10)
                accentColor.setFill()
                UIBezierPath(roundedRect: fill, cornerRadius: 5).fill()
            }
            cy += 16

            let budgetAttr: [NSAttributedString.Key: Any] = [
                .font: font(11, weight: .medium), .foregroundColor: grayText,
            ]
            ("\(balance.totalSpent.formattedCurrency) / \(project.budget.formattedCurrency) — \(Int(frac * 100))% utilise" as NSString)
                .draw(at: CGPoint(x: margin, y: cy), withAttributes: budgetAttr)
            cy += 18
        }

        return cy
    }

    // MARK: - Séparateurs

    private static func drawSeparator(y: CGFloat) -> CGFloat {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y + 8))
        path.addLine(to: CGPoint(x: margin + contentW, y: y + 8))
        grayLight.setStroke()
        path.lineWidth = 1
        path.stroke()
        return y + 16
    }

    private static func drawThinSeparator(y: CGFloat, indentLeft: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin + indentLeft, y: y))
        path.addLine(to: CGPoint(x: margin + contentW, y: y))
        UIColor(white: 0.93, alpha: 1).setStroke()
        path.lineWidth = 0.5
        path.stroke()
    }

    // MARK: - Balance

    private static func drawBalance(
        balance: BalanceResult,
        p1Name: String, p2Name: String,
        y: CGFloat
    ) -> CGFloat {
        let boxH: CGFloat = 56
        let box = CGRect(x: margin, y: y, width: contentW, height: boxH)

        let bgColor: UIColor
        let fgColor: UIColor
        let text: String

        switch balance.status {
        case .balanced:
            bgColor = UIColor(red: 0xE8 / 255, green: 0xF5 / 255, blue: 0xE9 / 255, alpha: 1)
            fgColor = UIColor(red: 0x2E / 255, green: 0x7D / 255, blue: 0x32 / 255, alpha: 1)
            text = "Equilibre — chacun a paye sa part"
        case .partner2OwesPartner1(let amt):
            bgColor = p2Color.withAlphaComponent(0.1)
            fgColor = p2Color
            text = "\(p2Name) doit \(amt.formattedCurrency) a \(p1Name)"
        case .partner1OwesPartner2(let amt):
            bgColor = p1Color.withAlphaComponent(0.1)
            fgColor = p1Color
            text = "\(p1Name) doit \(amt.formattedCurrency) a \(p2Name)"
        }

        bgColor.setFill()
        UIBezierPath(roundedRect: box, cornerRadius: 8).fill()

        let attr: [NSAttributedString.Key: Any] = [
            .font: font(15, weight: .semibold), .foregroundColor: fgColor,
        ]
        let ns = text as NSString
        let sz = ns.size(withAttributes: attr)
        ns.draw(
            at: CGPoint(x: margin + (contentW - sz.width) / 2, y: y + (boxH - sz.height) / 2),
            withAttributes: attr
        )

        return y + boxH + 16
    }

    // MARK: - Statistiques

    private static func drawStats(
        balance: BalanceResult,
        p1Name: String, p2Name: String,
        p1Count: Int, p2Count: Int,
        y: CGFloat
    ) -> CGFloat {
        let colW = (contentW - 1) / 2

        drawPartnerCol(
            name: p1Name, amount: balance.partner1Spent, count: p1Count,
            color: p1Color, x: margin, y: y
        )

        // Ligne verticale
        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin + colW, y: y))
        line.addLine(to: CGPoint(x: margin + colW, y: y + 60))
        grayLight.setStroke()
        line.lineWidth = 1
        line.stroke()

        drawPartnerCol(
            name: p2Name, amount: balance.partner2Spent, count: p2Count,
            color: p2Color, x: margin + colW + 1, y: y
        )

        return y + 70 + 16
    }

    private static func drawPartnerCol(
        name: String, amount: Decimal, count: Int,
        color: UIColor, x: CGFloat, y: CGFloat
    ) {
        let pad: CGFloat = 12

        // Point coloré
        color.setFill()
        UIBezierPath(ovalIn: CGRect(x: x + pad, y: y + 4, width: 8, height: 8)).fill()

        // Nom
        (name as NSString).draw(
            at: CGPoint(x: x + pad + 14, y: y),
            withAttributes: [.font: font(13, weight: .medium), .foregroundColor: grayText]
        )

        // Montant
        (amount.formattedCurrency as NSString).draw(
            at: CGPoint(x: x + pad, y: y + 20),
            withAttributes: [.font: font(18, weight: .bold), .foregroundColor: color]
        )

        // Nombre de dépenses
        ("\(count) depense\(count == 1 ? "" : "s")" as NSString).draw(
            at: CGPoint(x: x + pad, y: y + 46),
            withAttributes: [.font: font(11), .foregroundColor: grayText]
        )
    }

    // MARK: - Titre de section

    private static func drawSectionTitle(_ title: String, y: CGFloat) {
        (title as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [
                .font: font(14, weight: .semibold),
                .foregroundColor: accentColor,
            ]
        )
    }

    // MARK: - Ligne dépense

    private static func drawExpenseRow(
        expense: Expense,
        p1Name: String, p2Name: String,
        y: CGFloat
    ) {
        let isP1 = expense.paidBy == .partner1
        let color = isP1 ? p1Color : p2Color
        let payerName = isP1 ? p1Name : p2Name

        // Avatar cercle
        color.setFill()
        UIBezierPath(ovalIn: CGRect(x: margin, y: y + 6, width: 24, height: 24)).fill()

        let initial = String(payerName.prefix(1)).uppercased() as NSString
        let initAttr: [NSAttributedString.Key: Any] = [
            .font: font(12, weight: .bold), .foregroundColor: UIColor.white,
        ]
        let initSz = initial.size(withAttributes: initAttr)
        initial.draw(
            at: CGPoint(x: margin + (24 - initSz.width) / 2, y: y + 6 + (24 - initSz.height) / 2),
            withAttributes: initAttr
        )

        // Titre
        let titleX = margin + 32
        let titleMaxW = contentW - 32 - 100
        (expense.title as NSString).draw(
            in: CGRect(x: titleX, y: y + 4, width: titleMaxW, height: 18),
            withAttributes: [.font: font(13), .foregroundColor: UIColor.black]
        )

        // Date
        (expense.date.formatted(date: .abbreviated, time: .omitted) as NSString).draw(
            at: CGPoint(x: titleX, y: y + 20),
            withAttributes: [.font: font(11), .foregroundColor: grayText]
        )

        // Montant aligné à droite
        let amtAttr: [NSAttributedString.Key: Any] = [
            .font: font(13, weight: .semibold), .foregroundColor: color,
        ]
        let amtStr = expense.amount.formattedCurrency as NSString
        let amtW = amtStr.size(withAttributes: amtAttr).width
        amtStr.draw(
            at: CGPoint(x: margin + contentW - amtW, y: y + 10),
            withAttributes: amtAttr
        )
    }

    // MARK: - Pied de page

    private static func drawFooter(page: Int, total: Int) {
        let footerY = pageH - margin - 4

        // Centre
        let centerAttr: [NSAttributedString.Key: Any] = [
            .font: font(9), .foregroundColor: grayText,
        ]
        let dateStr = Date.now.formatted(date: .abbreviated, time: .omitted)
        let center = "Genere par DuoSpend — \(dateStr)" as NSString
        let centerW = center.size(withAttributes: centerAttr).width
        center.draw(
            at: CGPoint(x: (pageW - centerW) / 2, y: footerY),
            withAttributes: centerAttr
        )

        // Numéro de page
        let pageAttr: [NSAttributedString.Key: Any] = [
            .font: font(9, weight: .medium), .foregroundColor: grayText,
        ]
        let pageStr = "\(page)/\(total)" as NSString
        let pageW2 = pageStr.size(withAttributes: pageAttr).width
        pageStr.draw(
            at: CGPoint(x: margin + contentW - pageW2, y: footerY),
            withAttributes: pageAttr
        )
    }
}
