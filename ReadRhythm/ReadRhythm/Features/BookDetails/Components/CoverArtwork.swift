//
//  CoverArtwork.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 25.10.25.
//


//
//  CoverArtwork.swift
//  ReadRhythm
//
//  Kontext → Warum → Wie
//  Kontext: Einheitliche Darstellung eines Buchcovers in der App (Discover, Library, Detail).
//  Warum: Wir wollen ein wiederverwendbares, konsistentes Cover mit:
//         - echtem Remote-Thumbnail (Google Books)
//         - sanftem Placeholder mit Initialen, falls kein Bild da ist
//         - abgerundeten Ecken, Border, Shadow gemäß Design Tokens
//  Wie: Eine eigenständige SwiftUI-View, die überall eingebunden werden kann,
//       ohne dass jede View selbst AsyncImage / Placeholder bauen muss.
//
//  Created by Vu Minh Khoi Ha on 25.10.25.
//

import SwiftUI

/// Zeigt ein Buchcover:
/// - bevorzugt das echte Thumbnail-Bild (z. B. von Google Books)
/// - sonst ein Placeholder mit Initialen.
/// Größe wird von außen via `width` / `height` vorgegeben (kein Hardcode intern).
///
/// Usage:
/// ```swift
/// CoverArtwork(
///     thumbnailURLString: book.thumbnailURL,
///     titleForInitials: book.title,
///     width: 100,
///     height: 140
/// )
/// ```
struct CoverArtwork: View {
    /// Remote-URL als String? (z. B. von Google Books thumbnail)
    let thumbnailURLString: String?

    /// Fallback-Titel für Initialen (z. B. "Atomic Habits")
    let titleForInitials: String

    /// Zielgröße fürs Cover (wird vom aufrufenden Screen entschieden)
    let width: CGFloat
    let height: CGFloat

    /// Abgeleitete URL (optional gültig)
    private var thumbnailURL: URL? {
        guard let raw = thumbnailURLString,
              let url = URL(string: raw) else {
            return nil
        }
        return url
    }

    var body: some View {
        ZStack {
            // Hintergrund-Basis (sichtbar bei Loading / Placeholder / Fehler)
            RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                .fill(AppColors.Semantic.bgElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                        .stroke(
                            AppColors.Semantic.borderMuted,
                            lineWidth: 0.5
                        )
                )

            if let url = thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Laden → wir lassen einfach den Background + kleinen Spinner
                        ProgressView()
                            .tint(AppColors.Semantic.textSecondary)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
                            )
                    case .failure:
                        placeholderInitials
                    @unknown default:
                        placeholderInitials
                    }
                }
                .frame(width: width, height: height)
                .clipped()
            } else {
                // Kein Bild → Placeholder mit Initialen
                placeholderInitials
                    .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
        )
        .shadow(color: AppShadow.elevation1, radius: 4, x: 0, y: 2)
        .accessibilityHidden(true) // Bild ist dekorativ
    }

    /// Placeholder-Kachel mit Initialen
    private var placeholderInitials: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.Semantic.bgElevated,
                    AppColors.Semantic.bgPrimary.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(initials(from: titleForInitials))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.Semantic.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.m, style: .continuous)
        )
    }

    /// Erzeugt bis zu 2 Initialen aus dem Buchtitel.
    private func initials(from text: String) -> String {
        let parts = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.map { String($0) }.joined().uppercased()
    }
}


// MARK: - Preview (DEBUG only)
#if DEBUG
struct CoverArtwork_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CoverArtwork(
                thumbnailURLString: "https://books.google.com/some/thumbnail.jpg",
                titleForInitials: "Calm Your Mind",
                width: 100,
                height: 140
            )

            CoverArtwork(
                thumbnailURLString: nil,
                titleForInitials: "Deep Work",
                width: 100,
                height: 140
            )
        }
        .padding()
        .background(Color.black.opacity(0.05))
    }
}
#endif
